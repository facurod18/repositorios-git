# Employee Attrition Prediction

## Overview

This project analyzes employee attrition and builds a classification model to estimate which employees are more likely to leave the company.

The goal is to show an end-to-end machine learning workflow in Python: data validation, exploratory analysis, preprocessing, model comparison, threshold optimization, feature importance, and business interpretation.

This is a curated portfolio version based on an academic notebook. The original course notebook is not modified and is not published here.

## Business Problem

Employee turnover can be expensive. Companies may want to identify groups with higher attrition risk so that HR teams can investigate causes, improve retention strategies, and prioritize interventions.

This project asks:

- Which employee characteristics are associated with attrition?
- Can a machine learning model identify employees at higher attrition risk?
- Which tradeoffs appear between catching attrition cases and avoiding false alarms?

## Dataset

The dataset used locally is:

```text
projects/employee-attrition-prediction/data/raw/WA_Fn-UseC_-HR-Employee-Attrition.csv
```

The raw dataset is not committed to this repository. It is kept locally in `data/raw/` because dataset redistribution rights should always be checked before publishing.

Dataset shape verified locally:

- `1,470` rows
- `35` columns
- Target variable: `Attrition`
- Positive class: `Yes`

## Methods

The project uses:

- Exploratory data analysis
- Train/test split with stratification
- Preprocessing with `ColumnTransformer`
- One-hot encoding for categorical variables
- Logistic regression with class balancing
- Random forest with class balancing
- Confusion matrix
- Accuracy, precision, recall, F1, ROC-AUC, and average precision
- Business threshold optimization
- Feature importance analysis

## Verified Results

The analysis was executed locally with the HR attrition dataset.

| Model | ROC-AUC | Avg. Precision | Recall | Precision | F1 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Logistic Regression | 0.865 | 0.684 | 0.809 | 0.418 | 0.551 |
| Random Forest | 0.841 | 0.583 | 0.404 | 0.528 | 0.458 |

The logistic regression model is selected as the operational model because it performs better on ROC-AUC, average precision, recall, and F1. The random forest has higher accuracy, but that metric is less informative here because the target is imbalanced and the business objective is to identify employees at risk of leaving.

Business threshold analysis:

| Scenario | Net value |
| --- | ---: |
| No action | -1,175,000 USD |
| Universal bonus | 57,800 USD |
| Logistic regression, threshold 0.50 | 379,200 USD |
| Logistic regression, optimized threshold 0.39 | 480,400 USD |

The optimized threshold is `0.39`, which improves the estimated business value by contacting a broader group of employees at risk of leaving. This section is based on explicit assumptions about attrition cost and retention bonus cost, so it should be interpreted as a decision-support exercise rather than a production financial forecast.

## How to Run

From the repository root:

```bash
python3 projects/employee-attrition-prediction/notebooks/employee_attrition_prediction.py
```

The script creates:

- `figures/attrition_distribution.png`
- `figures/monthly_income_by_attrition.png`
- `figures/overtime_attrition_rate.png`
- `figures/confusion_matrix_logistic_regression.png`
- `figures/roc_curve_comparison.png`
- `figures/top_logistic_features.png`
- `figures/threshold_business_value.png`
- `reports/model_metrics.csv`
- `reports/business_scenarios.csv`
- `reports/threshold_business_value.csv`
- `reports/top_logistic_features.csv`

## Key Takeaways

- Attrition is imbalanced: most employees do not leave.
- Model evaluation should prioritize recall, precision, F1, ROC-AUC, and average precision, not accuracy alone.
- The final model choice is based on comparison between logistic regression and random forest, not on an arbitrary preference.
- Overtime, income, job role, career stage, and satisfaction-related variables are relevant factors to inspect.
- The decision threshold can be optimized according to business costs and benefits.
- Model outputs should support HR investigation, not automatic decisions about employees.

## Espanol

Este proyecto analiza la rotacion de empleados y entrena modelos de clasificacion para estimar riesgo de attrition. El objetivo para portfolio es mostrar un flujo completo de machine learning en Python: preparacion de datos, entrenamiento, evaluacion, visualizaciones, interpretacion y comunicacion de resultados para un problema de negocio.
