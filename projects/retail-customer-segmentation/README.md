# Retail Customer Segmentation with K-Means

## Overview

This project segments retail customers using K-Means clustering to support marketing, CRM, and customer strategy decisions.

The goal is to show an end-to-end unsupervised learning workflow in Python: data validation, feature engineering, scaling, cluster selection, K-Means modeling, PCA visualization, customer profiling, and business recommendations.

This is a curated portfolio version based on an academic machine learning exercise. The original course notebook is not modified and is not published here.

## Business Problem

Retail and e-commerce teams often need to understand customer heterogeneity before designing campaigns, loyalty programs, pricing strategies, or digital engagement initiatives.

This project asks:

- Which customer groups show similar purchasing and digital behavior?
- How many segments provide a useful balance between model quality and business interpretability?
- Which segments appear higher value, digitally engaged, or at risk of low engagement?
- What marketing actions could be assigned to each customer segment?

## Dataset

The dataset used locally is:

```text
projects/retail-customer-segmentation/data/raw/clientes_retail_segmentacion.csv
```

The script can also download the dataset from the public course URL if the local file is missing.

Raw data is not committed to this repository. It is kept locally in `data/raw/` because portfolio repositories should avoid redistributing datasets unless rights are explicit.

Dataset shape verified locally:

- `830` rows
- `9` columns
- Unit of analysis: retail customer

Main variables:

- `edad`
- `ingreso_anual_usd`
- `frecuencia_compra_mensual`
- `ticket_promedio_usd`
- `score_digital`
- `antiguedad_meses`
- `canal_preferido`
- `region`

## Methods

The project uses:

- Data audit and validation
- Feature engineering for estimated monthly value
- Standardization with `StandardScaler`
- K-Means clustering
- Elbow method using inertia
- Silhouette score comparison
- PCA for 2D visualization
- Segment profile tables
- Segment-level business recommendations
- Channel and region profiling

## Verified Results

The analysis was executed locally with the retail customer dataset.

Model selection:

| K | Inertia | Silhouette |
| ---: | ---: | ---: |
| 2 | 4013.081 | 0.285 |
| 3 | 2842.032 | 0.338 |
| 4 | 2074.515 | 0.381 |
| 5 | 1686.277 | 0.396 |
| 6 | 1568.679 | 0.358 |
| 7 | 1463.286 | 0.324 |
| 8 | 1389.732 | 0.309 |

The selected solution uses `K = 5`, which has the highest silhouette score among the tested values while still producing interpretable customer groups.

Segment summary:

| Segment | Business label | Customers | Share | Avg. monthly value | Recommended action |
| ---: | --- | ---: | ---: | ---: | --- |
| 0 | High-value loyal customers | 158 | 19.04% | 856.44 USD | Loyalty benefits, premium bundles, retention campaigns |
| 1 | Affluent occasional customers | 134 | 16.14% | 142.23 USD | Premium cross-selling and second-purchase incentives |
| 2 | Established relationship customers | 176 | 21.20% | 350.88 USD | Tenure-based benefits and relevant category recommendations |
| 3 | Low-engagement price-sensitive customers | 179 | 21.57% | 54.51 USD | Reactivation offers, onboarding nudges, low-friction promotions |
| 4 | Digital-first frequent shoppers | 183 | 22.05% | 293.21 USD | App/web campaigns, personalized recommendations, automated journeys |

Generated reports:

- `reports/dataset_summary.csv`
- `reports/model_selection.csv`
- `reports/segment_profiles.csv`
- `reports/segment_channel_mix.csv`
- `reports/segment_region_mix.csv`
- `reports/segment_recommendations.csv`

Generated figures:

- `figures/elbow_silhouette.png`
- `figures/pca_customer_segments.png`
- `figures/segment_size.png`
- `figures/segment_profiles_heatmap.png`
- `figures/channel_mix_by_segment.png`
- `figures/monthly_value_by_segment.png`

## How to Run

From the repository root:

```bash
python3 projects/retail-customer-segmentation/notebooks/customer_segmentation_kmeans.py
```

If the local CSV is not present, the script attempts to download it from the source URL used in the course material.

## Key Takeaways

- Scaling is essential before K-Means because customer income, frequency, ticket size, digital score, and tenure are measured on different scales.
- The final number of clusters is chosen using both quantitative metrics and business interpretability.
- PCA is used only for visualization; clustering is performed on the scaled feature set.
- Segment profiles translate model output into actionable business language.
- The project is directly relevant to marketing analytics, CRM, customer strategy, e-commerce, and product growth roles.

## Espanol

Este proyecto transforma un ejercicio academico de K-Means en un caso aplicado de segmentacion de clientes retail. El foco de portfolio esta en mostrar un flujo profesional: preparacion de datos, seleccion de variables, escalado, eleccion de K, entrenamiento, visualizacion, perfilado de segmentos y recomendaciones de negocio para marketing y CRM.
