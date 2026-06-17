"""Employee Attrition Prediction.

Portfolio project: classification workflow for an HR attrition dataset.
Run from the repository root:

    python3 projects/employee-attrition-prediction/notebooks/employee_attrition_prediction.py
"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    ConfusionMatrixDisplay,
    accuracy_score,
    average_precision_score,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
    roc_curve,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


PROJECT_DIR = Path("projects/employee-attrition-prediction")
DATA_PATH = PROJECT_DIR / "data/raw/WA_Fn-UseC_-HR-Employee-Attrition.csv"
FIGURES_DIR = PROJECT_DIR / "figures"
REPORTS_DIR = PROJECT_DIR / "reports"

RANDOM_STATE = 50404258
POSITIVE_CLASS = "Yes"
ATTRITION_COST = 25_000
RETENTION_BONUS_COST = 3_800


def make_ohe() -> OneHotEncoder:
    """Create a OneHotEncoder compatible with different scikit-learn versions."""
    try:
        return OneHotEncoder(handle_unknown="ignore", sparse_output=False)
    except TypeError:
        return OneHotEncoder(handle_unknown="ignore", sparse=False)


def save_plot(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight", facecolor="white")
    plt.close()


def evaluate_model(name: str, y_true: pd.Series, y_pred: np.ndarray, y_score: np.ndarray) -> dict:
    return {
        "model": name,
        "accuracy": accuracy_score(y_true, y_pred),
        "precision": precision_score(y_true, y_pred, zero_division=0),
        "recall": recall_score(y_true, y_pred, zero_division=0),
        "f1": f1_score(y_true, y_pred, zero_division=0),
        "roc_auc": roc_auc_score(y_true, y_score),
        "average_precision": average_precision_score(y_true, y_score),
    }


def business_value(y_true: pd.Series, y_pred: np.ndarray) -> dict:
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred).ravel()
    predicted_positive = tp + fp
    net_value = (tp * ATTRITION_COST) - (predicted_positive * RETENTION_BONUS_COST) - (fn * ATTRITION_COST)

    return {
        "tn": tn,
        "fp": fp,
        "fn": fn,
        "tp": tp,
        "predicted_positive": predicted_positive,
        "net_value_usd": net_value,
    }


def main() -> None:
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    if not DATA_PATH.exists():
        raise FileNotFoundError(
            f"Dataset not found at {DATA_PATH}. "
            "Place the raw CSV there before running this script."
        )

    df = pd.read_csv(DATA_PATH)
    required_columns = {"Attrition", "EmployeeNumber"}
    missing_columns = required_columns.difference(df.columns)
    if missing_columns:
        raise ValueError(f"Missing required columns: {sorted(missing_columns)}")

    print("Dataset shape:", df.shape)
    print("\nMissing values by column:")
    print(df.isna().sum().sort_values(ascending=False).head(10))
    print("\nAttrition distribution:")
    print(df["Attrition"].value_counts(normalize=True).rename("share"))

    # ---- Exploratory Analysis ---------------------------------------------

    sns.set_theme(style="whitegrid")

    attrition_counts = df["Attrition"].value_counts().rename_axis("Attrition").reset_index(name="count")
    attrition_counts["share"] = attrition_counts["count"] / attrition_counts["count"].sum()

    plt.figure(figsize=(8, 5))
    ax = sns.barplot(data=attrition_counts, x="Attrition", y="share", hue="Attrition", palette="Set2", legend=False)
    ax.set_title("Employee Attrition Distribution", fontweight="bold")
    ax.set_xlabel("Attrition")
    ax.set_ylabel("Share of employees")
    ax.yaxis.set_major_formatter(lambda x, _: f"{x:.0%}")
    save_plot(FIGURES_DIR / "attrition_distribution.png")

    plt.figure(figsize=(8, 5))
    ax = sns.boxplot(data=df, x="Attrition", y="MonthlyIncome", hue="Attrition", palette="Set2", legend=False)
    ax.set_title("Monthly Income by Attrition Status", fontweight="bold")
    ax.set_xlabel("Attrition")
    ax.set_ylabel("Monthly income")
    save_plot(FIGURES_DIR / "monthly_income_by_attrition.png")

    overtime_rate = (
        df.groupby("OverTime")["Attrition"]
        .apply(lambda values: (values == POSITIVE_CLASS).mean())
        .reset_index(name="attrition_rate")
    )

    plt.figure(figsize=(8, 5))
    ax = sns.barplot(data=overtime_rate, x="OverTime", y="attrition_rate", hue="OverTime", palette="Set2", legend=False)
    ax.set_title("Attrition Rate by Overtime Status", fontweight="bold")
    ax.set_xlabel("Overtime")
    ax.set_ylabel("Attrition rate")
    ax.yaxis.set_major_formatter(lambda x, _: f"{x:.0%}")
    save_plot(FIGURES_DIR / "overtime_attrition_rate.png")

    # ---- Modeling ----------------------------------------------------------

    y = (df["Attrition"] == POSITIVE_CLASS).astype(int)
    drop_columns = [
        "Attrition",
        "EmployeeNumber",
        "EmployeeCount",
        "Over18",
        "StandardHours",
    ]
    X = df.drop(columns=[col for col in drop_columns if col in df.columns])

    categorical_features = X.select_dtypes(include=["object"]).columns.tolist()
    numeric_features = X.select_dtypes(include=["number", "bool"]).columns.tolist()

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.20,
        stratify=y,
        random_state=RANDOM_STATE,
    )

    logistic_preprocessor = ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), numeric_features),
            ("cat", make_ohe(), categorical_features),
        ]
    )

    tree_preprocessor = ColumnTransformer(
        transformers=[
            ("num", "passthrough", numeric_features),
            ("cat", make_ohe(), categorical_features),
        ]
    )

    models = {
        "Logistic Regression": Pipeline(
            steps=[
                ("preprocess", logistic_preprocessor),
                (
                    "model",
                    LogisticRegression(
                        max_iter=2000,
                        class_weight="balanced",
                        random_state=RANDOM_STATE,
                    ),
                ),
            ]
        ),
        "Random Forest": Pipeline(
            steps=[
                ("preprocess", tree_preprocessor),
                (
                    "model",
                    RandomForestClassifier(
                        n_estimators=300,
                        min_samples_leaf=5,
                        class_weight="balanced",
                        random_state=RANDOM_STATE,
                    ),
                ),
            ]
        ),
    }

    metrics = []
    roc_data = {}

    for name, model in models.items():
        model.fit(X_train, y_train)
        y_score = model.predict_proba(X_test)[:, 1]
        y_pred = (y_score >= 0.5).astype(int)
        metrics.append(evaluate_model(name, y_test, y_pred, y_score))
        roc_data[name] = roc_curve(y_test, y_score)

        if name == "Logistic Regression":
            cm = confusion_matrix(y_test, y_pred)
            disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=["No", "Yes"])
            disp.plot(cmap="Blues", values_format="d")
            plt.title("Confusion Matrix - Logistic Regression", fontweight="bold")
            save_plot(FIGURES_DIR / "confusion_matrix_logistic_regression.png")

    metrics_df = pd.DataFrame(metrics).sort_values("roc_auc", ascending=False)
    metrics_df.to_csv(REPORTS_DIR / "model_metrics.csv", index=False)

    print("\nModel metrics:")
    print(metrics_df.to_string(index=False))

    # ---- Business Threshold Optimization -----------------------------------

    logistic_scores = models["Logistic Regression"].predict_proba(X_test)[:, 1]
    threshold_rows = []
    for threshold in np.arange(0.01, 1.00, 0.01):
        y_pred_threshold = (logistic_scores >= threshold).astype(int)
        row = {
            "threshold": threshold,
            **business_value(y_test, y_pred_threshold),
            **evaluate_model("Logistic Regression", y_test, y_pred_threshold, logistic_scores),
        }
        threshold_rows.append(row)

    threshold_df = pd.DataFrame(threshold_rows)
    best_threshold_row = threshold_df.sort_values("net_value_usd", ascending=False).iloc[0]
    threshold_df.to_csv(REPORTS_DIR / "threshold_business_value.csv", index=False)

    no_action_value = -int(y_test.sum()) * ATTRITION_COST
    universal_bonus_value = int(y_test.sum()) * ATTRITION_COST - len(y_test) * RETENTION_BONUS_COST
    default_threshold_value = threshold_df.loc[
        np.isclose(threshold_df["threshold"], 0.50),
        "net_value_usd",
    ].iloc[0]

    scenario_df = pd.DataFrame(
        [
            {"scenario": "no_action", "net_value_usd": no_action_value},
            {"scenario": "universal_bonus", "net_value_usd": universal_bonus_value},
            {"scenario": "logistic_threshold_0.50", "net_value_usd": default_threshold_value},
            {
                "scenario": "logistic_optimal_threshold",
                "threshold": best_threshold_row["threshold"],
                "net_value_usd": best_threshold_row["net_value_usd"],
            },
        ]
    )
    scenario_df.to_csv(REPORTS_DIR / "business_scenarios.csv", index=False)

    print("\nBusiness threshold optimization:")
    print("Attrition cost assumption:", ATTRITION_COST)
    print("Retention bonus cost assumption:", RETENTION_BONUS_COST)
    print("Best threshold:", round(best_threshold_row["threshold"], 2))
    print("Best net value:", int(best_threshold_row["net_value_usd"]))
    print("\nBusiness scenarios:")
    print(scenario_df.to_string(index=False))

    plt.figure(figsize=(8, 5))
    plt.plot(threshold_df["threshold"], threshold_df["net_value_usd"], color="#2D9CDB", linewidth=2)
    plt.axvline(best_threshold_row["threshold"], color="#E76F51", linestyle="--", label="Optimal threshold")
    plt.axhline(0, color="gray", linestyle=":")
    plt.title("Business Value by Decision Threshold", fontweight="bold")
    plt.xlabel("Decision threshold")
    plt.ylabel("Net value (USD)")
    plt.legend()
    save_plot(FIGURES_DIR / "threshold_business_value.png")

    plt.figure(figsize=(8, 5))
    for name, (fpr, tpr, _) in roc_data.items():
        auc_value = metrics_df.loc[metrics_df["model"] == name, "roc_auc"].iloc[0]
        plt.plot(fpr, tpr, linewidth=2, label=f"{name} (AUC = {auc_value:.3f})")
    plt.plot([0, 1], [0, 1], linestyle="--", color="gray", label="Random baseline")
    plt.title("ROC Curve Comparison", fontweight="bold")
    plt.xlabel("False positive rate")
    plt.ylabel("True positive rate")
    plt.legend()
    save_plot(FIGURES_DIR / "roc_curve_comparison.png")

    logistic_model = models["Logistic Regression"]
    feature_names = logistic_model.named_steps["preprocess"].get_feature_names_out()
    coefficients = logistic_model.named_steps["model"].coef_[0]
    feature_importance = (
        pd.DataFrame({"feature": feature_names, "coefficient": coefficients})
        .assign(abs_coefficient=lambda data: data["coefficient"].abs())
        .sort_values("abs_coefficient", ascending=False)
        .head(15)
    )

    feature_importance.to_csv(REPORTS_DIR / "top_logistic_features.csv", index=False)

    plt.figure(figsize=(9, 6))
    ax = sns.barplot(
        data=feature_importance.sort_values("coefficient"),
        x="coefficient",
        y="feature",
        color="#2D9CDB",
    )
    ax.set_title("Top Logistic Regression Features", fontweight="bold")
    ax.set_xlabel("Coefficient")
    ax.set_ylabel("")
    save_plot(FIGURES_DIR / "top_logistic_features.png")


if __name__ == "__main__":
    main()
