# Credit Risk & Default Prediction
# Portfolio version of a data analytics course project.

# ---- 0. Packages ------------------------------------------------------------

required_packages <- c(
  "dplyr",
  "ggplot2",
  "readr",
  "readxl",
  "janitor",
  "rpart",
  "rpart.plot",
  "scales"
)

missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]
if (length(missing_packages) > 0) {
  stop(
    "Missing packages: ",
    paste(missing_packages, collapse = ", "),
    "\nInstall them before running the analysis."
  )
}

library(dplyr)
library(ggplot2)
library(readr)
library(readxl)
library(janitor)
library(rpart)
library(rpart.plot)

# ---- 1. Project Paths -------------------------------------------------------

project_dir <- "projects/credit-risk-default"
data_path <- file.path(project_dir, "data/raw/PROYECTO.xlsx")
figures_dir <- file.path(project_dir, "figures")
portfolio_colors <- c("No" = "#2D9CDB", "Si" = "#E76F51")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(data_path)) {
  stop(
    "Dataset not found. Place the raw file at: ",
    data_path,
    "\nThe dataset is intentionally ignored by Git because redistribution rights are not confirmed."
  )
}

# ---- 2. Load Data -----------------------------------------------------------

credit <- read_excel(data_path) %>%
  clean_names(case = "none")

required_columns <- c(
  "IngresosCliente",
  "CreditoDisponible",
  "MontoPrestamo",
  "Educacion",
  "EstadoCivil",
  "Edad",
  "Default",
  "Genero",
  "RegionResidencia",
  "NumeroDependientes",
  "SectorEmpleo"
)

missing_columns <- setdiff(required_columns, names(credit))
if (length(missing_columns) > 0) {
  stop("Missing required columns: ", paste(missing_columns, collapse = ", "))
}

# ---- 3. Initial Checks ------------------------------------------------------

cat("\nRows and columns:\n")
print(dim(credit))

cat("\nMissing values by column:\n")
print(credit %>% summarise(across(everything(), ~ sum(is.na(.x)))))

credit <- credit %>%
  mutate(
    Default = factor(Default, levels = c("No", "Si")),
    Educacion = factor(Educacion),
    EstadoCivil = factor(EstadoCivil),
    Genero = factor(Genero),
    RegionResidencia = factor(RegionResidencia),
    SectorEmpleo = factor(SectorEmpleo)
  )

if (any(is.na(credit$Default))) {
  stop("Default contains values other than 'No' or 'Si'. Check target encoding.")
}

# ---- 4. Exploratory Data Analysis ------------------------------------------

default_distribution <- credit %>%
  count(Default) %>%
  mutate(share = n / sum(n))

cat("\nDefault distribution:\n")
print(default_distribution)

p_default <- ggplot(default_distribution, aes(x = Default, y = share, fill = Default)) +
  geom_col(width = 0.65, show.legend = FALSE) +
  scale_fill_manual(values = portfolio_colors) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Default Rate Distribution",
    x = "Default",
    y = "Share of customers"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "default_rate_distribution.png"),
  plot = p_default,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

numeric_variables <- c(
  "IngresosCliente",
  "MontoPrestamo",
  "CreditoDisponible",
  "Edad",
  "NumeroDependientes"
)

cat("\nCorrelation matrix:\n")
print(
  credit %>%
    select(any_of(numeric_variables)) %>%
    cor(use = "pairwise.complete.obs") %>%
    round(2)
)

p_income_loan <- ggplot(credit, aes(x = IngresosCliente, y = MontoPrestamo, color = Default)) +
  geom_point(alpha = 0.18, size = 0.8) +
  scale_color_manual(values = portfolio_colors) +
  labs(
    title = "Loan Amount vs Customer Income",
    x = "Customer income",
    y = "Loan amount",
    color = "Default"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "loan_amount_vs_income.png"),
  plot = p_income_loan,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

p_default_loan <- ggplot(credit, aes(x = Default, y = MontoPrestamo, fill = Default)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = portfolio_colors) +
  labs(
    title = "Loan Amount by Default Status",
    x = "Default",
    y = "Loan amount"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "loan_amount_by_default.png"),
  plot = p_default_loan,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ---- 5. Train/Test Split ----------------------------------------------------

set.seed(50404258)

train_index <- sample(seq_len(nrow(credit)), size = floor(0.7 * nrow(credit)))

train_data <- credit[train_index, ]
test_data <- credit[-train_index, ]

# ---- 6. Models --------------------------------------------------------------

# Both models use the same predictors so the comparison is like for like.
model_formula <- Default ~ IngresosCliente + MontoPrestamo + CreditoDisponible +
  NumeroDependientes + Educacion + Genero + EstadoCivil

# 6.1 Classification tree: readable decision rules for a credit committee.
tree_model <- rpart(
  model_formula,
  data = train_data,
  method = "class"
)

cat("\nClassification tree summary:\n")
print(tree_model)

png(
  filename = file.path(figures_dir, "classification_tree.png"),
  width = 1200,
  height = 800
)
rpart.plot(tree_model, type = 3, extra = 104, fallen.leaves = TRUE)
dev.off()

# 6.2 Logistic regression: standard scoring baseline in credit risk, and the
# reference every tree-based model should be required to beat.
logistic_model <- glm(
  model_formula,
  data = train_data,
  family = binomial(link = "logit")
)

cat("\nLogistic regression coefficients (odds ratios):\n")
print(round(exp(coef(logistic_model)), 3))

# ---- 7. Predictions and Evaluation -----------------------------------------

roc_auc_binary <- function(actual, score, positive = "Si") {
  actual_positive <- actual == positive
  n_positive <- sum(actual_positive)
  n_negative <- sum(!actual_positive)

  if (n_positive == 0 || n_negative == 0) {
    return(NA_real_)
  }

  ranks <- rank(score, ties.method = "average")
  (sum(ranks[actual_positive]) - n_positive * (n_positive + 1) / 2) /
    (n_positive * n_negative)
}

# Precision and recall at every distinct score threshold. Average precision is
# the area under that curve, computed as the recall-weighted mean of precision.
precision_recall_curve <- function(actual, score, positive = "Si") {
  actual_positive <- actual == positive
  ordering <- order(score, decreasing = TRUE)
  labels <- actual_positive[ordering]

  tp <- cumsum(labels)
  fp <- cumsum(!labels)
  precision <- tp / (tp + fp)
  recall <- tp / sum(actual_positive)

  # Keep the last row of each tied score block so the curve is single valued.
  keep <- c(diff(score[ordering]) != 0, TRUE)

  tibble::tibble(
    threshold = score[ordering][keep],
    precision = precision[keep],
    recall = recall[keep]
  )
}

average_precision <- function(pr) {
  sum(diff(c(0, pr$recall)) * pr$precision)
}

classification_metrics <- function(actual, score, threshold = 0.5, positive = "Si") {
  predicted <- factor(
    if_else(score >= threshold, "Si", "No"),
    levels = c("No", "Si")
  )

  confusion_matrix <- table(Actual = actual, Predicted = predicted)

  tn <- confusion_matrix["No", "No"]
  fp <- confusion_matrix["No", "Si"]
  fn <- confusion_matrix["Si", "No"]
  tp <- confusion_matrix["Si", "Si"]

  accuracy <- (tp + tn) / sum(confusion_matrix)
  sensitivity <- tp / (tp + fn)
  specificity <- tn / (tn + fp)
  precision <- tp / (tp + fp)
  f1_score <- 2 * precision * sensitivity / (precision + sensitivity)

  list(
    confusion_matrix = confusion_matrix,
    metrics = c(
      accuracy = accuracy,
      error_rate = 1 - accuracy,
      sensitivity = sensitivity,
      specificity = specificity,
      precision = precision,
      f1_score = f1_score,
      roc_auc = roc_auc_binary(actual, score, positive),
      average_precision = average_precision(precision_recall_curve(actual, score, positive))
    )
  )
}

model_scores <- list(
  `Classification tree` = predict(tree_model, newdata = test_data, type = "prob")[, "Si"],
  `Logistic regression` = predict(logistic_model, newdata = test_data, type = "response")
)

model_metrics <- bind_rows(lapply(names(model_scores), function(model_name) {
  evaluation <- classification_metrics(test_data$Default, model_scores[[model_name]])

  cat("\nConfusion matrix -", model_name, "\n")
  print(evaluation$confusion_matrix)

  tibble::tibble(
    model = model_name,
    metric = names(evaluation$metrics),
    value = as.numeric(evaluation$metrics)
  )
}))

metric_comparison <- tibble::tibble(
  metric = names(classification_metrics(test_data$Default, model_scores[[1]])$metrics),
  tree = model_metrics$value[model_metrics$model == "Classification tree"],
  logistic = model_metrics$value[model_metrics$model == "Logistic regression"]
)

cat("\nModel metrics on test set:\n")
print(metric_comparison, n = Inf)

write_csv(
  model_metrics,
  file.path(project_dir, "reports/model_metrics.csv")
)

# ---- 7.1 Precision-Recall Curve ---------------------------------------------

# The classes are imbalanced, so the PR curve describes performance on the
# minority class (defaults) more faithfully than a ROC curve does.
pr_data <- bind_rows(lapply(names(model_scores), function(model_name) {
  precision_recall_curve(test_data$Default, model_scores[[model_name]]) %>%
    mutate(model = model_name)
}))

default_rate <- mean(test_data$Default == "Si")

p_pr <- ggplot(pr_data, aes(x = recall, y = precision, color = model)) +
  geom_step(direction = "vh", linewidth = 0.9) +
  geom_hline(
    yintercept = default_rate,
    linetype = "dashed",
    color = "grey40"
  ) +
  annotate(
    "text",
    x = 0.02,
    y = default_rate + 0.03,
    label = sprintf("Random classifier (%.1f%% default rate)", 100 * default_rate),
    hjust = 0,
    size = 3.2,
    color = "grey30"
  ) +
  scale_color_manual(values = c(
    "Classification tree" = "#E76F51",
    "Logistic regression" = "#2D9CDB"
  )) +
  scale_x_continuous(labels = scales::percent, limits = c(0, 1)) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(
    title = "Precision-Recall Curve on the Test Set",
    subtitle = "Higher curves identify more defaulters at the same false alarm cost",
    x = "Recall (share of defaulters caught)",
    y = "Precision (share of flagged customers who truly default)",
    color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "precision_recall_curve.png"),
  plot = p_pr,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

# ---- 8. Interpretation Notes ------------------------------------------------

cat("\nInterpretation guide:\n")
cat("- Sensitivity shows how well the model identifies customers who default.\n")
cat("- Specificity shows how well the model identifies customers who do not default.\n")
cat("- In credit risk, false negatives can be costly because risky customers are missed.\n")
cat("- False positives can also be costly because potentially good customers may be rejected.\n")
cat("- Accuracy is inflated by the majority class here, so it is not the deciding metric.\n")
cat("- Average precision summarises the precision-recall curve and is the fairest\n")
cat("  single number when the positive class is the minority.\n")
