from pathlib import Path
import warnings

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler


warnings.filterwarnings("ignore")
sns.set_theme(style="whitegrid")

RANDOM_STATE = 42
DATA_URL = "https://raw.githubusercontent.com/gustavovazquez/datasets/main/clientes_retail_segmentacion.csv"
FEATURES = [
    "edad",
    "ingreso_anual_usd",
    "frecuencia_compra_mensual",
    "ticket_promedio_usd",
    "score_digital",
    "antiguedad_meses",
    "valor_mensual_estimado",
]


def get_project_dir() -> Path:
    script_path = Path(__file__).resolve()
    return script_path.parents[1]


PROJECT_DIR = get_project_dir()
RAW_DIR = PROJECT_DIR / "data" / "raw"
FIGURES_DIR = PROJECT_DIR / "figures"
REPORTS_DIR = PROJECT_DIR / "reports"
RAW_DIR.mkdir(parents=True, exist_ok=True)
FIGURES_DIR.mkdir(parents=True, exist_ok=True)
REPORTS_DIR.mkdir(parents=True, exist_ok=True)


def save_table(df: pd.DataFrame, name: str) -> None:
    df.to_csv(REPORTS_DIR / name, index=False)


def save_figure(name: str) -> None:
    plt.tight_layout()
    plt.savefig(FIGURES_DIR / name, dpi=160, bbox_inches="tight")
    plt.close()


def load_data() -> pd.DataFrame:
    local_path = RAW_DIR / "clientes_retail_segmentacion.csv"
    if local_path.exists():
        return pd.read_csv(local_path)

    df = pd.read_csv(DATA_URL)
    df.to_csv(local_path, index=False)
    return df


def audit_data(df: pd.DataFrame) -> None:
    summary = pd.DataFrame(
        {
            "column": df.columns,
            "dtype": [str(df[col].dtype) for col in df.columns],
            "missing": [df[col].isna().sum() for col in df.columns],
            "missing_pct": [(df[col].isna().mean() * 100).round(2) for col in df.columns],
            "unique_values": [df[col].nunique() for col in df.columns],
        }
    )
    save_table(summary, "dataset_summary.csv")


def prepare_features(df: pd.DataFrame) -> tuple[pd.DataFrame, np.ndarray, StandardScaler]:
    data = df.copy()
    data["valor_mensual_estimado"] = (
        data["frecuencia_compra_mensual"] * data["ticket_promedio_usd"]
    )

    X = data[FEATURES].copy()
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    return data, X_scaled, scaler


def evaluate_k(X_scaled: np.ndarray, k_min: int = 2, k_max: int = 8) -> pd.DataFrame:
    rows = []
    for k in range(k_min, k_max + 1):
        model = KMeans(n_clusters=k, random_state=RANDOM_STATE, n_init=20)
        labels = model.fit_predict(X_scaled)
        rows.append(
            {
                "k": k,
                "inertia": model.inertia_,
                "silhouette": silhouette_score(X_scaled, labels),
            }
        )
    selection = pd.DataFrame(rows)
    save_table(selection, "model_selection.csv")
    return selection


def choose_k(selection: pd.DataFrame) -> int:
    top = selection.sort_values("silhouette", ascending=False).iloc[0]
    return int(top["k"])


def plot_model_selection(selection: pd.DataFrame) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5))

    sns.lineplot(data=selection, x="k", y="inertia", marker="o", ax=axes[0], color="#26547C")
    axes[0].set_title("Elbow method")
    axes[0].set_xlabel("Number of clusters")
    axes[0].set_ylabel("Inertia")

    sns.lineplot(data=selection, x="k", y="silhouette", marker="o", ax=axes[1], color="#D62828")
    axes[1].set_title("Silhouette score")
    axes[1].set_xlabel("Number of clusters")
    axes[1].set_ylabel("Average silhouette")

    save_figure("elbow_silhouette.png")


def fit_segments(data: pd.DataFrame, X_scaled: np.ndarray, k: int) -> tuple[pd.DataFrame, KMeans]:
    model = KMeans(n_clusters=k, random_state=RANDOM_STATE, n_init=20)
    data = data.copy()
    data["segment"] = model.fit_predict(X_scaled)
    return data, model


def build_profiles(data: pd.DataFrame) -> pd.DataFrame:
    profiles = (
        data.groupby("segment")
        .agg(
            customers=("cliente_id", "count"),
            avg_age=("edad", "mean"),
            avg_income_usd=("ingreso_anual_usd", "mean"),
            avg_purchase_frequency=("frecuencia_compra_mensual", "mean"),
            avg_ticket_usd=("ticket_promedio_usd", "mean"),
            avg_digital_score=("score_digital", "mean"),
            avg_tenure_months=("antiguedad_meses", "mean"),
            avg_monthly_value_usd=("valor_mensual_estimado", "mean"),
        )
        .reset_index()
    )

    numeric_cols = profiles.columns.drop(["segment", "customers"])
    profiles[numeric_cols] = profiles[numeric_cols].round(2)
    profiles["customer_share_pct"] = (profiles["customers"] / profiles["customers"].sum() * 100).round(2)
    return profiles


def assign_business_labels(profiles: pd.DataFrame) -> pd.DataFrame:
    profiles = profiles.copy()
    max_value = profiles["avg_monthly_value_usd"].max()
    max_digital = profiles["avg_digital_score"].max()
    max_tenure = profiles["avg_tenure_months"].max()
    min_value = profiles["avg_monthly_value_usd"].min()
    median_income = profiles["avg_income_usd"].median()
    median_frequency = profiles["avg_purchase_frequency"].median()

    labels = []
    recommendations = []
    for _, row in profiles.iterrows():
        if row["avg_monthly_value_usd"] == max_value:
            labels.append("High-value loyal customers")
            recommendations.append("Prioritize loyalty benefits, premium bundles, and retention campaigns.")
        elif row["avg_digital_score"] == max_digital:
            labels.append("Digital-first frequent shoppers")
            recommendations.append("Use app/web campaigns, personalized recommendations, and automated journeys.")
        elif row["avg_monthly_value_usd"] == min_value:
            labels.append("Low-engagement price-sensitive customers")
            recommendations.append("Test reactivation offers, onboarding nudges, and low-friction promotions.")
        elif row["avg_income_usd"] > median_income and row["avg_purchase_frequency"] < median_frequency:
            labels.append("Affluent occasional customers")
            recommendations.append("Use premium cross-selling and second-purchase incentives to increase frequency.")
        elif row["avg_tenure_months"] == max_tenure:
            labels.append("Established relationship customers")
            recommendations.append("Protect retention with tenure-based benefits and relevant category recommendations.")
        else:
            labels.append("Growth-potential customers")
            recommendations.append("Increase purchase frequency with cross-selling and targeted category offers.")

    profiles["business_label"] = labels
    profiles["recommended_action"] = recommendations
    return profiles


def save_mix_tables(data: pd.DataFrame) -> None:
    channel_mix = (
        pd.crosstab(data["segment"], data["canal_preferido"], normalize="index") * 100
    ).round(2).reset_index()
    region_mix = (
        pd.crosstab(data["segment"], data["region"], normalize="index") * 100
    ).round(2).reset_index()

    save_table(channel_mix, "segment_channel_mix.csv")
    save_table(region_mix, "segment_region_mix.csv")


def plot_segments(data: pd.DataFrame, X_scaled: np.ndarray) -> None:
    pca = PCA(n_components=2, random_state=RANDOM_STATE)
    coords = pca.fit_transform(X_scaled)
    plot_df = pd.DataFrame(
        {
            "pc1": coords[:, 0],
            "pc2": coords[:, 1],
            "segment": data["segment"].astype(str),
        }
    )

    plt.figure(figsize=(9, 6))
    sns.scatterplot(data=plot_df, x="pc1", y="pc2", hue="segment", palette="tab10", alpha=0.75)
    plt.title("Customer segments visualized with PCA")
    plt.xlabel(f"PC1 ({pca.explained_variance_ratio_[0] * 100:.1f}% variance)")
    plt.ylabel(f"PC2 ({pca.explained_variance_ratio_[1] * 100:.1f}% variance)")
    plt.legend(title="Segment")
    save_figure("pca_customer_segments.png")


def plot_segment_size(data: pd.DataFrame) -> None:
    size = data["segment"].value_counts().sort_index().reset_index()
    size.columns = ["segment", "customers"]

    plt.figure(figsize=(8, 5))
    sns.barplot(data=size, x="segment", y="customers", color="#26547C")
    plt.title("Segment size")
    plt.xlabel("Segment")
    plt.ylabel("Customers")
    save_figure("segment_size.png")


def plot_profiles_heatmap(profiles: pd.DataFrame) -> None:
    heatmap_cols = [
        "avg_age",
        "avg_income_usd",
        "avg_purchase_frequency",
        "avg_ticket_usd",
        "avg_digital_score",
        "avg_tenure_months",
        "avg_monthly_value_usd",
    ]
    heatmap_data = profiles.set_index("segment")[heatmap_cols]
    heatmap_scaled = (heatmap_data - heatmap_data.mean()) / heatmap_data.std()

    plt.figure(figsize=(10, 5.5))
    sns.heatmap(heatmap_scaled, cmap="vlag", center=0, annot=True, fmt=".1f")
    plt.title("Segment profile heatmap")
    plt.xlabel("Profile variable")
    plt.ylabel("Segment")
    save_figure("segment_profiles_heatmap.png")


def plot_channel_mix(data: pd.DataFrame) -> None:
    channel_counts = (
        data.groupby(["segment", "canal_preferido"])
        .size()
        .reset_index(name="customers")
    )
    channel_counts["share"] = channel_counts.groupby("segment")["customers"].transform(
        lambda x: x / x.sum() * 100
    )

    plt.figure(figsize=(9, 5))
    sns.barplot(
        data=channel_counts,
        x="segment",
        y="share",
        hue="canal_preferido",
        palette=["#26547C", "#2A9D8F", "#F4A261"],
    )
    plt.title("Preferred channel mix by segment")
    plt.xlabel("Segment")
    plt.ylabel("Customer share (%)")
    plt.legend(title="Preferred channel")
    save_figure("channel_mix_by_segment.png")


def plot_monthly_value(data: pd.DataFrame) -> None:
    plt.figure(figsize=(9, 5))
    sns.boxplot(data=data, x="segment", y="valor_mensual_estimado", color="#2A9D8F")
    plt.title("Estimated monthly value by segment")
    plt.xlabel("Segment")
    plt.ylabel("Frequency x average ticket (USD)")
    save_figure("monthly_value_by_segment.png")


def main() -> None:
    df = load_data()
    audit_data(df)

    data, X_scaled, _ = prepare_features(df)
    selection = evaluate_k(X_scaled)
    chosen_k = choose_k(selection)
    plot_model_selection(selection)

    segmented, _ = fit_segments(data, X_scaled, chosen_k)
    profiles = build_profiles(segmented)
    recommendations = assign_business_labels(profiles)

    save_table(profiles, "segment_profiles.csv")
    save_table(
        recommendations[
            [
                "segment",
                "business_label",
                "customers",
                "customer_share_pct",
                "avg_monthly_value_usd",
                "avg_digital_score",
                "recommended_action",
            ]
        ],
        "segment_recommendations.csv",
    )
    save_mix_tables(segmented)

    plot_segments(segmented, X_scaled)
    plot_segment_size(segmented)
    plot_profiles_heatmap(profiles)
    plot_channel_mix(segmented)
    plot_monthly_value(segmented)

    print("Retail customer segmentation completed.")
    print(f"Rows: {len(segmented)}")
    print(f"Features: {', '.join(FEATURES)}")
    print(f"Selected k: {chosen_k}")
    print("\nModel selection:")
    print(selection.to_string(index=False))
    print("\nSegment recommendations:")
    print((REPORTS_DIR / "segment_recommendations.csv").read_text())


if __name__ == "__main__":
    main()
