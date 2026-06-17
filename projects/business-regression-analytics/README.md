# Business Regression Analytics

## Overview

This project uses two small business-oriented datasets to demonstrate how linear regression can support practical decision-making in marketing and consumer analytics.

The project started from university exercises in a data analytics course and was rewritten as a portfolio case study. The goal is to show a clean, reproducible workflow: data loading, exploratory analysis, model training, train/test evaluation, visualization, interpretation, and awareness of model limitations.

## Case Studies

The datasets are analyzed separately:

1. **Marketing analytics:** How strongly is social media ad spending associated with monthly sales?
2. **Consumer spending analytics:** How well can annual credit card charges be estimated from household income and household size?

These cases are kept in the same project because both are compact business regression exercises. The datasets are not merged because they represent different units of analysis and different business contexts.

## Dataset

The datasets were provided by a professor for a university course. Because redistribution rights are not confirmed, raw data is not included in this public repository.

To reproduce the analysis locally, place the files here:

```text
projects/business-regression-analytics/data/raw/ecommerce.xlsx
projects/business-regression-analytics/data/raw/Consumer.xlsx
```

Expected variables:

Marketing dataset:

- `Mes`
- `RRSS`
- `Ventas`

Consumer dataset:

- `Income`
- `Household_Size`
- `Amount_Charged`

## Methods

The project uses:

- Exploratory data analysis
- Correlation analysis
- Simple linear regression
- Multiple linear regression
- Train/test split
- RMSE, MAE, and R-squared
- Residual diagnostics
- Out-of-range prediction checks

## Verified Results

The analysis was executed locally with both course datasets.

Marketing model:

| Metric | Value |
| --- | ---: |
| Test RMSE | 1.151 |
| Test MAE | 0.960 |
| Train R-squared | 0.799 |
| Correlation | 0.893 |

Consumer model:

| Metric | Value |
| --- | ---: |
| Test RMSE | 300.000 |
| Test MAE | 239.843 |
| Train R-squared | 0.820 |
| RMSE test/train ratio | 0.738 |

## How to Run

From the repository root:

```bash
Rscript projects/business-regression-analytics/notebooks/business_regression_analysis.R
```

The script creates:

- `figures/marketing_sales_vs_ad_spend.png`
- `figures/marketing_residuals.png`
- `figures/consumer_actual_vs_predicted.png`
- `figures/consumer_residuals.png`
- `reports/model_metrics.csv`

## Key Takeaways

- Social media ad spend is strongly and positively associated with sales in the marketing dataset.
- The marketing model should not be used for ad spend values far outside the observed range.
- Household size and income explain a large share of variation in credit card charges in the consumer dataset.
- Small datasets are useful for demonstrating method and interpretation, but larger datasets would be needed for production-quality decisions.
- The datasets should not be combined because they describe different units, variables, and business contexts.

## Espanol

Este proyecto convierte ejercicios universitarios de regresion en un caso de portfolio aplicado a negocio. No se mezclan los datasets porque tratan unidades y temas distintos: marketing/ventas por un lado, y consumo de hogares por otro. El valor para portfolio esta en mostrar regresion lineal simple y multiple, metricas de evaluacion, visualizaciones y criterio metodologico.
