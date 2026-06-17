# Business Regression Analytics
# Portfolio version of data analytics course exercises.

# ---- 0. Packages ------------------------------------------------------------

required_packages <- c(
  "dplyr",
  "ggplot2",
  "readr",
  "readxl",
  "janitor",
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

# ---- 1. Project Paths -------------------------------------------------------

project_dir <- "projects/business-regression-analytics"
data_dir <- file.path(project_dir, "data/raw")
figures_dir <- file.path(project_dir, "figures")
reports_dir <- file.path(project_dir, "reports")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(reports_dir, recursive = TRUE, showWarnings = FALSE)

ecommerce_path <- file.path(data_dir, "ecommerce.xlsx")
consumer_path <- file.path(data_dir, "Consumer.xlsx")

missing_files <- c(ecommerce_path, consumer_path)[!file.exists(c(ecommerce_path, consumer_path))]
if (length(missing_files) > 0) {
  stop(
    "Missing dataset file(s): ",
    paste(missing_files, collapse = ", "),
    "\nRaw data is intentionally ignored by Git."
  )
}

# ---- 2. Helper Functions ----------------------------------------------------

regression_metrics <- function(actual, predicted, model = NULL) {
  residuals <- actual - predicted

  tibble::tibble(
    metric = c("rmse", "mae", "r_squared"),
    value = c(
      sqrt(mean(residuals^2)),
      mean(abs(residuals)),
      if (is.null(model)) NA_real_ else summary(model)$r.squared
    )
  )
}

assert_columns <- function(data, required_columns, dataset_name) {
  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    stop(
      dataset_name,
      " is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
}

# ---- 3. Load Data -----------------------------------------------------------

ecommerce <- read_excel(ecommerce_path) %>%
  clean_names(case = "none")

consumer <- read_excel(consumer_path) %>%
  clean_names(case = "none")

assert_columns(ecommerce, c("Mes", "RRSS", "Ventas"), "ecommerce")
assert_columns(consumer, c("Income", "Household_Size", "Amount_Charged"), "Consumer")

cat("\nEcommerce dimensions:\n")
print(dim(ecommerce))

cat("\nConsumer dimensions:\n")
print(dim(consumer))

cat("\nMissing values - ecommerce:\n")
print(ecommerce %>% summarise(across(everything(), ~ sum(is.na(.x)))))

cat("\nMissing values - consumer:\n")
print(consumer %>% summarise(across(everything(), ~ sum(is.na(.x)))))

# ---- 4. Case 1: Marketing Regression ---------------------------------------

marketing_correlation <- cor(ecommerce$RRSS, ecommerce$Ventas)

set.seed(2025)
marketing_train_index <- sample(seq_len(nrow(ecommerce)), size = floor(0.8 * nrow(ecommerce)))
marketing_train <- ecommerce[marketing_train_index, ]
marketing_test <- ecommerce[-marketing_train_index, ]

marketing_model <- lm(Ventas ~ RRSS, data = marketing_train)

marketing_predictions <- marketing_test %>%
  mutate(
    predicted_sales = predict(marketing_model, newdata = marketing_test),
    residual = Ventas - predicted_sales
  )

marketing_train_predictions <- marketing_train %>%
  mutate(predicted_sales = predict(marketing_model, newdata = marketing_train))

marketing_metrics <- tibble::tibble(
  project_case = "marketing_sales",
  metric = c("test_rmse", "test_mae", "train_r_squared", "correlation"),
  value = c(
    sqrt(mean(marketing_predictions$residual^2)),
    mean(abs(marketing_predictions$residual)),
    summary(marketing_model)$r.squared,
    marketing_correlation
  )
)

cat("\nMarketing model summary:\n")
print(summary(marketing_model))

cat("\nMarketing metrics:\n")
print(marketing_metrics)

marketing_plot <- ggplot(ecommerce, aes(x = RRSS, y = Ventas)) +
  geom_point(color = "#2D9CDB", size = 2.5, alpha = 0.85) +
  geom_smooth(method = "lm", se = TRUE, color = "#E76F51", linewidth = 1) +
  labs(
    title = "Monthly Sales vs Social Media Ad Spend",
    x = "Social media ad spend",
    y = "Sales"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "marketing_sales_vs_ad_spend.png"),
  plot = marketing_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

marketing_residual_plot <- ggplot(marketing_predictions, aes(x = predicted_sales, y = residual)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray45") +
  geom_point(color = "#2D9CDB", size = 2.5, alpha = 0.85) +
  labs(
    title = "Marketing Model Residuals",
    x = "Predicted sales",
    y = "Residual"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "marketing_residuals.png"),
  plot = marketing_residual_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

ad_spend_scenario <- 15000
observed_ad_spend_range <- range(ecommerce$RRSS)
scenario_prediction <- predict(marketing_model, newdata = data.frame(RRSS = ad_spend_scenario))

cat("\nMarketing scenario prediction:\n")
cat("Ad spend:", ad_spend_scenario, "\n")
cat("Predicted sales:", scenario_prediction, "\n")
cat("Observed ad spend range:", observed_ad_spend_range[1], "to", observed_ad_spend_range[2], "\n")
cat("Out of observed range:", ad_spend_scenario < observed_ad_spend_range[1] || ad_spend_scenario > observed_ad_spend_range[2], "\n")

# ---- 5. Case 2: Consumer Regression ----------------------------------------

set.seed(50404258)
consumer_train_index <- sample(seq_len(nrow(consumer)), size = floor(0.8 * nrow(consumer)))
consumer_train <- consumer[consumer_train_index, ]
consumer_test <- consumer[-consumer_train_index, ]

consumer_model <- lm(Amount_Charged ~ Household_Size + Income, data = consumer_train)

consumer_train_predictions <- consumer_train %>%
  mutate(
    predicted_amount = predict(consumer_model, newdata = consumer_train),
    residual = Amount_Charged - predicted_amount
  )

consumer_predictions <- consumer_test %>%
  mutate(
    predicted_amount = predict(consumer_model, newdata = consumer_test),
    residual = Amount_Charged - predicted_amount
  )

consumer_train_rmse <- sqrt(mean(consumer_train_predictions$residual^2))
consumer_test_rmse <- sqrt(mean(consumer_predictions$residual^2))

consumer_metrics <- tibble::tibble(
  project_case = "consumer_charges",
  metric = c("test_rmse", "test_mae", "train_r_squared", "rmse_test_train_ratio"),
  value = c(
    consumer_test_rmse,
    mean(abs(consumer_predictions$residual)),
    summary(consumer_model)$r.squared,
    consumer_test_rmse / consumer_train_rmse
  )
)

cat("\nConsumer model summary:\n")
print(summary(consumer_model))

cat("\nConsumer metrics:\n")
print(consumer_metrics)

consumer_actual_vs_predicted <- ggplot(consumer_predictions, aes(x = Amount_Charged, y = predicted_amount)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray45") +
  geom_point(color = "#2D9CDB", size = 2.8, alpha = 0.9) +
  labs(
    title = "Actual vs Predicted Credit Card Charges",
    x = "Actual amount charged",
    y = "Predicted amount charged"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "consumer_actual_vs_predicted.png"),
  plot = consumer_actual_vs_predicted,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

consumer_residual_plot <- ggplot(consumer_predictions, aes(x = predicted_amount, y = residual)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray45") +
  geom_point(color = "#2D9CDB", size = 2.8, alpha = 0.9) +
  labs(
    title = "Consumer Model Residuals",
    x = "Predicted amount charged",
    y = "Residual"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(figures_dir, "consumer_residuals.png"),
  plot = consumer_residual_plot,
  width = 8,
  height = 5,
  dpi = 300,
  bg = "white"
)

consumer_scenario <- data.frame(Household_Size = 4, Income = 50)
consumer_scenario_prediction <- predict(consumer_model, newdata = consumer_scenario)

cat("\nConsumer scenario prediction:\n")
print(consumer_scenario)
cat("Predicted annual credit card charge:", consumer_scenario_prediction, "\n")

# ---- 6. Export Metrics ------------------------------------------------------

all_metrics <- bind_rows(marketing_metrics, consumer_metrics)

write_csv(all_metrics, file.path(reports_dir, "model_metrics.csv"))

cat("\nSaved metrics to:\n")
cat(file.path(reports_dir, "model_metrics.csv"), "\n")
