# Bank Customer Churn Prediction

**Objective:** Predict which bank customers are likely to close their accounts (churn) using machine learning classification. This was a competitive Kaggle challenge evaluated on AUC-ROC.

**Team:** Facundo Rodríguez & Sofía Bojreibe (Master's in Data Science, UCU)

---

## Problem Statement

Customer churn is a critical challenge in the banking sector. Identifying customers at risk of leaving allows banks to implement proactive retention strategies. This project develops a predictive model to identify at-risk customers using historical behavioral and demographic data.

**Dataset:** Bank customer records with behavioral features, financial metrics, and churn outcome  
**Target Variable:** `Exited` (binary: 0 = retained, 1 = churned)  
**Evaluation Metric:** AUC-ROC (Area Under the Receiver Operating Characteristic curve)

---

## Approach

### 1. **Feature Engineering** 🔧
Beyond raw features, we created derived financial indicators:
- **Balance-related ratios**: `BalancePerProduct`, `BalancePerTenure`
- **Salary-to-balance dynamics**: `SalaryToBalanceRatio` 
- **Activity indicators**: `HasBalance`, `IsActiveInLastMonth`
- **Surname frequency**: `SurnameFreq` (captures regional/demographic patterns)

**Rationale:** Churn often depends on relative financial health, not absolute values. A customer with balanced wealth *relative to their tenure* is different from a new customer with the same absolute balance.

### 2. **Model Selection & Comparison** 🤖

We systematically compared 7 algorithms:

| Model | Key Metric | Notes |
|-------|-----------|-------|
| **Logistic Regression** | AUC ~0.73 | Baseline; interpretable but underfits |
| **Decision Tree** | AUC ~0.75 | Fast training; prone to overfitting |
| **Random Forest** | AUC ~0.82 | Strong baseline; good feature importance |
| **KNN** | AUC ~0.71 | Unstable; sensitive to scaling |
| **SVM** | AUC ~0.74 | Slow training; marginal improvement |
| **Gradient Boosting** | AUC ~0.84 | **Selected** ✅ Best AUC + robust |
| **HistGradientBoosting** | AUC ~0.83 | Modern, efficient; slightly lower AUC |

### 3. **Hyperparameter Optimization** 🎯

**Gradient Boosting** was selected for final tuning via `GridSearchCV`:

```python
param_grid = {
    'n_estimators':     [300, 500],
    'learning_rate':    [0.03, 0.05],
    'max_depth':        [3, 4],
    'subsample':        [0.8, 1.0],
    'min_samples_leaf': [1, 20],
}
```

**Search space:** 72 hyperparameter combinations  
**Validation:** 5-fold stratified cross-validation  
**Final validation:** 10-fold stratified CV on best model  
**Metric:** AUC-ROC (accounts for class imbalance naturally)

### 4. **Validation Strategy** ✔️

- **Train/test split:** Stratified (preserves churn ratio)
- **Cross-validation:** 5-fold for hyperparameter tuning, 10-fold for final evaluation
- **Holdout set:** Reserved for ROC-AUC vs. Precision-Recall visualization
- **Class imbalance:** Handled naturally by AUC metric (doesn't require class weights)

---

## Key Results

### Model Performance
- **Best Model:** Gradient Boosting Classifier
- **AUC-ROC (CV):** ~0.84 (10-fold)
- **Predicted & submitted:** Kaggle test set predictions

### Feature Importance
The model emphasizes:
1. **Tenure** — Most important. Long-tenured customers are stickier.
2. **Product count** — Customers with multiple products churn less.
3. **Geographic location** — Certain regions show higher churn propensity.
4. **Active member status** — Recent activity strongly predicts retention.
5. **Balance and salary ratios** — Derived features captured relative financial health.

### Insight
The most predictive features aren't just raw values—**customer engagement metrics** (tenure, products, activity) matter more than demographic factors alone.

---

## Project Structure

```
bank-churn-prediction/
├── notebooks/
│   └── bank_churn_prediction.ipynb    # Full analysis & modeling pipeline
├── data/
│   ├── train.csv                      # Training set
│   ├── test.csv                       # Test set (Kaggle submission)
│   └── submission.csv                 # Sample submission format
├── reports/
│   └── [model summaries & metrics]
├── figures/
│   └── [ROC curves, feature importance, confusion matrices]
└── README.md
```

---

## Technical Stack

| Component | Tool |
|-----------|------|
| Data manipulation | pandas, numpy |
| Preprocessing | scikit-learn (StandardScaler, OneHotEncoder, ColumnTransformer, Pipeline) |
| Modeling | scikit-learn (Logistic Regression, Decision Trees, Random Forest, Gradient Boosting, KNN, SVM) |
| Validation | Stratified K-Fold, GridSearchCV |
| Visualization | matplotlib, seaborn |

---

## How to Reproduce

1. **Place data files** in the `data/` folder:
   - `train.csv`
   - `test.csv`
   - `submission.csv` (sample)

2. **Run the notebook:**
   ```bash
   jupyter notebook notebooks/bank_churn_prediction.ipynb
   ```

3. **Output:** Predictions on test set saved for Kaggle submission.

---

## Lessons Learned

✅ **Gradient Boosting beats simpler models** — The extra complexity pays off with AUC gains.  
✅ **Feature engineering > hyperparameter tuning** — Derived financial ratios outperformed raw features.  
✅ **Stratified validation matters** — With class imbalance (churn ~20%), stratified splits prevented overfitting to majority class.  
✅ **Collaboration insight** — Defending modeling choices with a teammate forced clearer thinking and reduced biases.

---

## About This Project

This project was developed as part of a **Master's in Data Science** competitive challenge. It demonstrates:
- End-to-end machine learning pipeline
- Systematic model comparison
- Feature engineering for real business problems
- Robust validation practices
- Clear communication of results

---

## Authors

- **Facundo Rodríguez** — Feature engineering, model selection, hyperparameter optimization
- **Sofía Bojreibe** — Data exploration, preprocessing, evaluation framework

*Master's in Data Science, Universidad Católica del Uruguay (UCU)*

---

## Files

| File | Purpose |
|------|---------|
| `notebooks/bank_churn_prediction.ipynb` | Complete analysis: data loading, EDA, feature engineering, model comparison, hyperparameter tuning, validation, and predictions |

---

*Last updated: July 2026*
