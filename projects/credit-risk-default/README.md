# Credit Risk & Default Prediction

## Overview

This project analyzes a loan portfolio dataset to understand which borrower characteristics are associated with credit default and to build an interpretable classification model.

The project started as an academic assignment for a data analytics course and is being rewritten as a professional portfolio case study. The goal is not only to run a model, but to show a complete analytical workflow: exploratory analysis, hypothesis testing, classification, model evaluation, interpretation, and business-oriented recommendations.

## Business Problem

Financial institutions need to estimate the probability that a borrower will default on a loan. Better default prediction can support risk management, loan approval policies, credit limits, pricing decisions, and customer monitoring.

This project asks:

- Which customer and loan variables are most associated with default?
- Can an interpretable model classify customers by default risk?
- What tradeoffs appear between correctly identifying risky borrowers and avoiding false alarms?

## Dataset

The dataset was provided by a professor for a university course. Because the data source and redistribution rights are not fully clear, the raw dataset is not included in this public repository.

To reproduce the analysis locally, place the dataset in:

```text
projects/credit-risk-default/data/raw/PROYECTO.xlsx
```

The original analysis expects a data frame with variables similar to:

- `Default`
- `IngresosCliente`
- `MontoPrestamo`
- `CreditoDisponible`
- `Edad`
- `NumeroDependientes`
- `Educacion`
- `EstadoCivil`
- `Genero`
- `RegionResidencia`
- `SectorEmpleo`

## Methods

The project uses:

- Exploratory data analysis
- Correlation analysis and grouped summaries
- Hypothesis testing
- Classification tree modeling
- Train/test split
- Confusion matrix
- Accuracy, error rate, sensitivity, and specificity
- ROC-AUC
- Interpretation of decision rules

## Verified Results

The analysis was executed locally with the course dataset (`34,210` rows and `12` columns). The first baseline model is an interpretable classification tree.

Test-set metrics:

| Metric | Value |
| --- | ---: |
| Accuracy | 0.941 |
| Error rate | 0.059 |
| Sensitivity | 0.697 |
| Specificity | 0.995 |
| Precision | 0.970 |
| F1 score | 0.811 |
| ROC-AUC | 0.895 |

The model is very strong at identifying non-default customers, but sensitivity is lower than specificity. In a credit risk setting, this matters because false negatives can be costly: the model may miss some customers who eventually default.

## How to Run

From the repository root:

```bash
Rscript projects/credit-risk-default/notebooks/credit_risk_default_analysis.R
```

The script creates:

- `figures/default_rate_distribution.png`
- `figures/loan_amount_vs_income.png`
- `figures/loan_amount_by_default.png`
- `figures/classification_tree.png`
- `reports/model_metrics.csv`

## Planned Improvements

- Add logistic regression as a baseline model
- Compare decision tree, random forest, and logistic regression
- Add precision-recall evaluation
- Write a short final report with business recommendations

## Espanol

Este proyecto analiza una base de prestamos para estudiar que caracteristicas de clientes y creditos se asocian con el default. La idea es convertir una entrega universitaria en un caso de portfolio profesional: problema, datos, analisis, modelo, evaluacion, interpretacion y recomendaciones.

El script ya fue ejecutado localmente con el dataset real. La base no se sube a GitHub porque fue provista para una materia y no estan confirmados los permisos de redistribucion.
