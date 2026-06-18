# Uruguay Political Advertising Efficiency Analysis

## Overview

This project analyzes digital political advertising efficiency in Uruguay's 2024 electoral cycle, covering both internal party elections and national elections.

The goal is to show how public-interest campaign data can be transformed into an applied analytics workflow: data validation, currency normalization, exploratory analysis, efficiency metrics, statistical comparison, regression modeling, train/test evaluation, robustness-oriented interpretation, and clear communication of results.

This is a curated portfolio version based on an academic political science research project. The original research scripts and documents are kept locally and are not modified here.

## Research Problem

Political parties invest in digital advertising to reach voters, but more spending does not automatically imply more efficient reach. This project studies how efficiently parties converted advertising spend into impressions.

The project asks:

- How did advertising efficiency vary across parties?
- Did efficiency differ between Montevideo and the rest of the country?
- How did efficiency evolve over time as election day approached?
- Is there evidence of a nonlinear relationship between ad spend and impressions per USD?
- Can account characteristics and campaign timing help explain ad efficiency?

## Dataset

The analysis uses local Excel files derived from political advertising and page-level data:

```text
projects/uruguay-political-ad-efficiency/data/raw/BD_internas.xlsx
projects/uruguay-political-ad-efficiency/data/raw/anuncios_generales.xlsx
projects/uruguay-political-ad-efficiency/data/raw/BD_paginas.xlsx
projects/uruguay-political-ad-efficiency/data/raw/dolar.xlsx
```

Raw data is not committed to this repository. It is kept locally in `data/raw/` because redistribution rights and platform data constraints should be checked before publishing.

The curated pipeline uses USD directly and converts UYU to USD when a monthly exchange rate is available. Rows in unsupported currencies, or UYU rows without an available exchange rate, are excluded from the analytical sample and reported in `reports/currency_coverage.csv`.

Dataset shapes verified locally:

| File | Rows | Columns |
| --- | ---: | ---: |
| `BD_internas.xlsx` | 10,058 | 30 |
| `anuncios_generales.xlsx` | 8,002 | 28 |
| `BD_paginas.xlsx` | 660 | 5 |
| `dolar.xlsx` | 4 | 2 |

## Methods

The project uses:

- Currency normalization from UYU to USD
- Average spend and average impressions from Meta Ad Library ranges
- Efficiency metric: average impressions per average USD spent
- Party grouping into Frente Amplio, Partido Nacional, Partido Colorado, and Otros
- Montevideo vs Interior comparison
- Weekly efficiency trends
- Kruskal-Wallis tests for group differences
- Linear regression with campaign controls
- Quadratic spend term to detect nonlinear efficiency patterns
- Train/test RMSE comparison
- Feature and coefficient interpretation

## Verified Results

The curated analysis was executed locally with the Excel files listed above.

Key generated tables:

- `reports/dataset_summary.csv`
- `reports/currency_coverage.csv`
- `reports/party_efficiency_summary.csv`
- `reports/region_efficiency_summary.csv`
- `reports/statistical_tests.csv`
- `reports/model_metrics.csv`
- `reports/model_coefficients.csv`

Analytical sample after currency and data-quality filters:

| Election cycle | Rows used |
| --- | ---: |
| Internal elections | 2,916 |
| National elections | 6,021 |

Average efficiency by party:

| Election cycle | Highest mean efficiency | Mean impressions/USD | Median impressions/USD |
| --- | --- | ---: | ---: |
| Internal elections | Partido Colorado | 1,168.2 | 656.6 |
| National elections | Frente Amplio | 945.7 | 656.2 |

Group differences by party are statistically significant in both election cycles:

| Election cycle | Kruskal-Wallis p-value |
| --- | ---: |
| Internal elections | 2.17e-25 |
| National elections | 2.04e-63 |

Regression evaluation:

| Election cycle | Train RMSE | Test RMSE | Test/train ratio | Train R-squared | Spend turning point |
| --- | ---: | ---: | ---: | ---: | ---: |
| Internal elections | 856.8 | 835.2 | 0.975 | 0.099 | 963.9 USD |
| National elections | 727.3 | 698.8 | 0.961 | 0.097 | 6,649.5 USD |

The regression models are intentionally interpreted as exploratory decision-support models. They suggest nonlinear spend-efficiency patterns, but they should not be read as causal estimates.

Key generated figures:

- `figures/internal_party_efficiency.png`
- `figures/national_party_efficiency.png`
- `figures/internal_efficiency_region.png`
- `figures/national_efficiency_region.png`
- `figures/internal_weekly_efficiency.png`
- `figures/national_weekly_efficiency.png`
- `figures/internal_spend_efficiency_curve.png`
- `figures/national_spend_efficiency_curve.png`

## How to Run

From the repository root:

```bash
Rscript projects/uruguay-political-ad-efficiency/notebooks/political_ad_efficiency_analysis.R
```

The script expects the raw Excel files in:

```text
projects/uruguay-political-ad-efficiency/data/raw/
```

## Key Takeaways

- The project converts an academic political science research question into a reproducible analytics case study.
- The same logic used for political campaigns is transferable to marketing analytics, ad spend optimization, media planning, and public-sector data analysis.
- Efficiency is defined explicitly and reproducibly as impressions per USD, using midpoint estimates from ad library ranges.
- Currency treatment is conservative: unsupported currencies are excluded rather than treated as USD.
- Group comparisons are treated carefully because efficiency distributions are skewed and non-normal.
- Regression models are used as decision-support tools, not as causal proof.
- The strongest portfolio value is the combination of domain expertise, data cleaning, statistical testing, modeling, and communication.

## Espanol

Este proyecto analiza la eficiencia del gasto publicitario digital en campanas politicas uruguayas de 2024. La version de portfolio conserva la pregunta academica original, pero la presenta como un caso aplicado de analytics: limpieza de datos, normalizacion de moneda, metricas de eficiencia, visualizaciones, comparacion estadistica, modelos de regresion e interpretacion profesional.
