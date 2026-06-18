# Political advertising efficiency in Uruguay
# Curated portfolio version. Original academic scripts are not modified.

required_packages <- c("readxl", "dplyr", "tidyr", "ggplot2", "lubridate", "stringr")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop(
    "Missing required packages: ",
    paste(missing_packages, collapse = ", "),
    ". Install them before running this script.",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(lubridate)
  library(stringr)
})

get_project_dir <- function() {
  args <- commandArgs(FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)

  if (length(file_arg) > 0) {
    script_path <- normalizePath(sub("^--file=", "", file_arg[1]), mustWork = TRUE)
    return(normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE))
  }

  candidate <- file.path(getwd(), "projects", "uruguay-political-ad-efficiency")
  if (dir.exists(candidate)) {
    return(normalizePath(candidate, mustWork = TRUE))
  }

  stop("Could not locate project directory.", call. = FALSE)
}

project_dir <- get_project_dir()
raw_dir <- file.path(project_dir, "data", "raw")
figures_dir <- file.path(project_dir, "figures")
reports_dir <- file.path(project_dir, "reports")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(reports_dir, recursive = TRUE, showWarnings = FALSE)

theme_portfolio <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray35"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

party_colors <- c(
  "Frente Amplio" = "#26547C",
  "Partido Nacional" = "#2A9D8F",
  "Partido Colorado" = "#D62828",
  "Otros" = "#F4A261"
)

write_report <- function(data, filename) {
  utils::write.csv(data, file.path(reports_dir, filename), row.names = FALSE, na = "")
}

save_plot <- function(plot, filename, width = 9, height = 5.5) {
  ggsave(
    filename = file.path(figures_dir, filename),
    plot = plot,
    width = width,
    height = height,
    dpi = 150
  )
}

check_files <- function(files) {
  missing <- files[!file.exists(file.path(raw_dir, files))]
  if (length(missing) > 0) {
    stop(
      "Missing raw data files in ",
      raw_dir,
      ": ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
}

check_files(c("BD_internas.xlsx", "anuncios_generales.xlsx", "BD_paginas.xlsx", "dolar.xlsx"))

read_dollar <- function() {
  read_excel(file.path(raw_dir, "dolar.xlsx")) %>%
    mutate(fecha = format(as.Date(fecha), "%Y-%m"))
}

standardize_party <- function(x) {
  x <- as.character(x)
  x <- str_trim(x)
  dplyr::case_when(
    x %in% c("1", "1.0", "FA", "Frente Amplio") ~ "Frente Amplio",
    x %in% c("2", "2.0", "PN", "Partido Nacional") ~ "Partido Nacional",
    x %in% c("3", "3.0", "PC", "Partido Colorado") ~ "Partido Colorado",
    TRUE ~ "Otros"
  )
}

prepare_ads <- function(data, election_type, election_date) {
  dollar <- read_dollar()

  data %>%
    filter(is.na(Filtro) | Filtro == "") %>%
    mutate(
      election_type = election_type,
      ad_creation_time = as.Date(ad_creation_time),
      ad_delivery_start_time = as.Date(ad_delivery_start_time),
      ad_delivery_stop_time = as.Date(ad_delivery_stop_time),
      fecha = format(ad_creation_time, "%Y-%m"),
      part_org = factor(
        standardize_party(part_org),
        levels = c("Frente Amplio", "Partido Nacional", "Partido Colorado", "Otros")
      ),
      departamento_bin = if_else(departamento_nacional == "MO", "Montevideo", "Interior")
    ) %>%
    left_join(dollar, by = "fecha") %>%
    mutate(
      spend_lower = as.numeric(spend_lower),
      spend_upper = as.numeric(spend_upper),
      impressions_lower = as.numeric(impressions_lower),
      impressions_upper = as.numeric(impressions_upper),
      supported_currency = currency == "USD" | (currency == "UYU" & !is.na(dolar_prom)),
      spend_lower = case_when(
        currency == "USD" ~ spend_lower,
        currency == "UYU" & !is.na(dolar_prom) ~ spend_lower / dolar_prom,
        TRUE ~ NA_real_
      ),
      spend_upper = case_when(
        currency == "USD" ~ spend_upper,
        currency == "UYU" & !is.na(dolar_prom) ~ spend_upper / dolar_prom,
        TRUE ~ NA_real_
      ),
      impressions_upper = if_else(is.na(impressions_upper), impressions_lower + 99999, impressions_upper),
      promedio_impresiones = (impressions_lower + impressions_upper) / 2,
      promedio_gasto = (spend_lower + spend_upper) / 2,
      eficiencia = if_else(promedio_gasto > 0, promedio_impresiones / promedio_gasto, NA_real_),
      numero_dias = as.numeric(ad_delivery_stop_time - ad_delivery_start_time) + 1,
      dia_medio_anuncio = ad_delivery_start_time + floor(pmax(numero_dias - 1, 0) / 2),
      distancia_eleccion = as.numeric(as.Date(election_date) - dia_medio_anuncio),
      semana = floor_date(ad_delivery_start_time, "week")
    ) %>%
    filter(
      is.finite(eficiencia),
      eficiencia > 0,
      is.finite(promedio_gasto),
      promedio_gasto > 0,
      !is.na(part_org),
      !is.na(ad_delivery_start_time)
    )
}

internals_raw <- read_excel(file.path(raw_dir, "BD_internas.xlsx"), sheet = "BD")
nationals_raw <- read_excel(file.path(raw_dir, "anuncios_generales.xlsx"))
pages_raw <- read_excel(file.path(raw_dir, "BD_paginas.xlsx"))

currency_coverage <- function(data, label) {
  dollar <- read_dollar()

  data %>%
    mutate(
      election_type = label,
      ad_creation_time = as.Date(ad_creation_time),
      fecha = format(ad_creation_time, "%Y-%m")
    ) %>%
    left_join(dollar, by = "fecha") %>%
    mutate(
      conversion_status = case_when(
        currency == "USD" ~ "USD used directly",
        currency == "UYU" & !is.na(dolar_prom) ~ "UYU converted to USD",
        currency == "UYU" & is.na(dolar_prom) ~ "UYU missing exchange rate",
        TRUE ~ "Unsupported currency excluded"
      )
    ) %>%
    count(election_type, currency, conversion_status, name = "rows") %>%
    arrange(election_type, conversion_status, desc(rows))
}

write_report(
  bind_rows(
    currency_coverage(internals_raw, "Internal elections"),
    currency_coverage(nationals_raw, "National elections")
  ),
  "currency_coverage.csv"
)

internals <- prepare_ads(internals_raw, "Internal elections", "2024-06-30")
nationals <- prepare_ads(nationals_raw, "National elections", "2024-10-27") %>%
  mutate(ad_delivery_stop_time = pmin(ad_delivery_stop_time, as.Date("2024-10-27"), na.rm = TRUE))

all_ads <- bind_rows(internals, nationals)

dataset_summary <- tibble(
  dataset = c("Internal elections", "National elections"),
  raw_rows = c(nrow(internals_raw), nrow(nationals_raw)),
  modeling_rows = c(nrow(internals), nrow(nationals)),
  raw_columns = c(ncol(internals_raw), ncol(nationals_raw)),
  date_min = c(min(internals$ad_delivery_start_time, na.rm = TRUE), min(nationals$ad_delivery_start_time, na.rm = TRUE)),
  date_max = c(max(internals$ad_delivery_start_time, na.rm = TRUE), max(nationals$ad_delivery_start_time, na.rm = TRUE))
)
write_report(dataset_summary, "dataset_summary.csv")

party_summary <- all_ads %>%
  group_by(election_type, part_org) %>%
  summarise(
    ads = n(),
    total_spend_usd = sum(promedio_gasto, na.rm = TRUE),
    total_impressions = sum(promedio_impresiones, na.rm = TRUE),
    mean_efficiency = mean(eficiencia, na.rm = TRUE),
    median_efficiency = median(eficiencia, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(election_type, desc(mean_efficiency))
write_report(party_summary, "party_efficiency_summary.csv")

region_summary <- all_ads %>%
  group_by(election_type, departamento_bin, part_org) %>%
  summarise(
    ads = n(),
    mean_efficiency = mean(eficiencia, na.rm = TRUE),
    median_efficiency = median(eficiencia, na.rm = TRUE),
    total_spend_usd = sum(promedio_gasto, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(election_type, departamento_bin, desc(mean_efficiency))
write_report(region_summary, "region_efficiency_summary.csv")

statistical_tests <- all_ads %>%
  group_by(election_type) %>%
  summarise(
    kruskal_statistic = unname(kruskal.test(eficiencia ~ part_org)$statistic),
    kruskal_p_value = kruskal.test(eficiencia ~ part_org)$p.value,
    .groups = "drop"
  )
write_report(statistical_tests, "statistical_tests.csv")

make_party_plot <- function(data, title) {
  ggplot(data, aes(x = part_org, y = eficiencia, fill = part_org)) +
    geom_boxplot(outlier.alpha = 0.15, width = 0.62) +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 2.8, fill = "white") +
    scale_fill_manual(values = party_colors, drop = FALSE) +
    coord_cartesian(ylim = c(0, quantile(data$eficiencia, 0.95, na.rm = TRUE))) +
    labs(
      title = title,
      subtitle = "Distribution capped at the 95th percentile for readability",
      x = NULL,
      y = "Impressions per USD",
      fill = NULL
    ) +
    theme_portfolio()
}

make_region_plot <- function(data, title) {
  ggplot(data, aes(x = part_org, y = eficiencia, fill = part_org)) +
    geom_boxplot(outlier.alpha = 0.12, width = 0.62) +
    scale_fill_manual(values = party_colors, drop = FALSE) +
    facet_wrap(~departamento_bin) +
    coord_cartesian(ylim = c(0, quantile(data$eficiencia, 0.95, na.rm = TRUE))) +
    labs(
      title = title,
      subtitle = "Montevideo vs Interior comparison",
      x = NULL,
      y = "Impressions per USD",
      fill = NULL
    ) +
    theme_portfolio()
}

make_weekly_plot <- function(data, title) {
  weekly <- data %>%
    group_by(semana, part_org) %>%
    summarise(mean_efficiency = mean(eficiencia, na.rm = TRUE), ads = n(), .groups = "drop") %>%
    filter(ads >= 5)

  ggplot(weekly, aes(x = semana, y = mean_efficiency, color = part_org)) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 1.7) +
    scale_color_manual(values = party_colors, drop = FALSE) +
    labs(
      title = title,
      subtitle = "Weekly average efficiency, weeks with at least five ads",
      x = NULL,
      y = "Mean impressions per USD",
      color = NULL
    ) +
    theme_portfolio()
}

make_curve_plot <- function(data, title) {
  ggplot(data, aes(x = promedio_gasto, y = eficiencia, color = part_org)) +
    geom_point(alpha = 0.16, size = 1) +
    geom_smooth(method = "lm", formula = y ~ poly(x, 2, raw = TRUE), se = FALSE, linewidth = 1.1) +
    scale_color_manual(values = party_colors, drop = FALSE) +
    coord_cartesian(
      xlim = c(0, quantile(data$promedio_gasto, 0.98, na.rm = TRUE)),
      ylim = c(0, quantile(data$eficiencia, 0.95, na.rm = TRUE))
    ) +
    labs(
      title = title,
      subtitle = "Quadratic trend line by party, axes capped for readability",
      x = "Average ad spend (USD)",
      y = "Impressions per USD",
      color = NULL
    ) +
    theme_portfolio()
}

save_plot(make_party_plot(internals, "Advertising efficiency by party: internal elections"), "internal_party_efficiency.png")
save_plot(make_party_plot(nationals, "Advertising efficiency by party: national elections"), "national_party_efficiency.png")
save_plot(make_region_plot(internals, "Advertising efficiency by region: internal elections"), "internal_efficiency_region.png")
save_plot(make_region_plot(nationals, "Advertising efficiency by region: national elections"), "national_efficiency_region.png")
save_plot(make_weekly_plot(internals, "Weekly efficiency trend: internal elections"), "internal_weekly_efficiency.png")
save_plot(make_weekly_plot(nationals, "Weekly efficiency trend: national elections"), "national_weekly_efficiency.png")
save_plot(make_curve_plot(internals, "Spend-efficiency relationship: internal elections"), "internal_spend_efficiency_curve.png")
save_plot(make_curve_plot(nationals, "Spend-efficiency relationship: national elections"), "national_spend_efficiency_curve.png")

prepare_model_data <- function(data, pages, ad_count_name) {
  page_counts <- data %>%
    count(page_id, name = ad_count_name)

  parse_spanish_date <- function(x) {
    months <- c(
      "enero" = "01",
      "febrero" = "02",
      "marzo" = "03",
      "abril" = "04",
      "mayo" = "05",
      "junio" = "06",
      "julio" = "07",
      "agosto" = "08",
      "setiembre" = "09",
      "septiembre" = "09",
      "octubre" = "10",
      "noviembre" = "11",
      "diciembre" = "12"
    )

    text <- str_to_lower(str_squish(as.character(x)))
    day <- str_match(text, "^(\\d{1,2})")[, 2]
    month_name <- str_match(text, "de ([a-z]+) de")[, 2]
    year <- str_match(text, "(\\d{4})$")[, 2]
    month <- unname(months[month_name])
    parsed <- ifelse(
      !is.na(day) & !is.na(month) & !is.na(year),
      sprintf("%s-%s-%02d", year, month, as.integer(day)),
      NA_character_
    )
    as.Date(parsed)
  }

  pages_clean <- pages %>%
    mutate(
      page_id = as.character(page_id),
      followers = as.numeric(followers),
      num_admins = as.numeric(num_admins),
      creation_date = parse_spanish_date(creation_date),
      account_age_days = as.numeric(as.Date("2024-11-10") - creation_date)
    ) %>%
    select(page_id, followers, num_admins, account_age_days)

  data %>%
    mutate(page_id = as.character(page_id)) %>%
    left_join(page_counts, by = "page_id") %>%
    left_join(pages_clean, by = "page_id") %>%
    mutate(
      spend_squared = promedio_gasto^2,
      ads_per_day_to_election = .data[[ad_count_name]] / pmax(distancia_eleccion, 1),
      followers = if_else(is.na(followers), median(followers, na.rm = TRUE), followers),
      num_admins = if_else(is.na(num_admins), median(num_admins, na.rm = TRUE), num_admins),
      account_age_days = if_else(is.na(account_age_days), median(account_age_days, na.rm = TRUE), account_age_days),
      numero_dias = if_else(!is.finite(numero_dias) | numero_dias <= 0, 1, numero_dias)
    ) %>%
    filter(
      is.finite(eficiencia),
      is.finite(promedio_gasto),
      is.finite(spend_squared),
      is.finite(ads_per_day_to_election),
      is.finite(numero_dias),
      is.finite(followers),
      is.finite(num_admins),
      is.finite(account_age_days)
    )
}

fit_efficiency_model <- function(data, pages, label, ad_count_name) {
  model_data <- prepare_model_data(data, pages, ad_count_name)

  set.seed(180820)
  train_idx <- sample(seq_len(nrow(model_data)), size = floor(0.6 * nrow(model_data)))
  train_data <- model_data[train_idx, ]

  candidate_terms <- c(
    "part_org",
    "departamento_bin",
    "promedio_gasto",
    "spend_squared",
    "ads_per_day_to_election",
    "numero_dias",
    "followers",
    "num_admins",
    "account_age_days"
  )

  usable_terms <- candidate_terms[vapply(candidate_terms, function(term) {
    values <- train_data[[term]]
    if (is.factor(values) || is.character(values)) {
      return(length(unique(values[!is.na(values)])) >= 2)
    }
    length(unique(values[is.finite(values)])) >= 2
  }, logical(1))]

  model_formula <- as.formula(paste("eficiencia ~", paste(usable_terms, collapse = " + ")))
  model <- lm(
    model_formula,
    data = model_data,
    subset = train_idx
  )

  predictions <- predict(model, newdata = model_data)
  train_rmse <- sqrt(mean((model_data$eficiencia[train_idx] - predictions[train_idx])^2, na.rm = TRUE))
  test_rmse <- sqrt(mean((model_data$eficiencia[-train_idx] - predictions[-train_idx])^2, na.rm = TRUE))

  b1 <- coef(model)[["promedio_gasto"]]
  b2 <- coef(model)[["spend_squared"]]
  spend_turning_point <- if (!is.na(b1) && !is.na(b2) && b2 != 0) -b1 / (2 * b2) else NA_real_

  metrics <- tibble(
    election_type = label,
    rows_used = nrow(model_data),
    train_rows = length(train_idx),
    test_rows = nrow(model_data) - length(train_idx),
    train_rmse = train_rmse,
    test_rmse = test_rmse,
    rmse_test_train_ratio = test_rmse / train_rmse,
    r_squared_train = summary(model)$r.squared,
    spend_turning_point_usd = spend_turning_point
  )

  coefficients <- as.data.frame(summary(model)$coefficients)
  coefficients$term <- rownames(coefficients)
  rownames(coefficients) <- NULL
  coefficients <- coefficients %>%
    transmute(
      election_type = label,
      term = term,
      estimate = Estimate,
      std_error = `Std. Error`,
      statistic = `t value`,
      p_value = `Pr(>|t|)`
    )

  list(metrics = metrics, coefficients = coefficients)
}

internal_model <- fit_efficiency_model(internals, pages_raw, "Internal elections", "number_ads_internal")
national_model <- fit_efficiency_model(nationals, pages_raw, "National elections", "number_ads_national")

model_metrics <- bind_rows(internal_model$metrics, national_model$metrics)
model_coefficients <- bind_rows(internal_model$coefficients, national_model$coefficients)

write_report(model_metrics, "model_metrics.csv")
write_report(model_coefficients, "model_coefficients.csv")

cat("\nPolitical advertising efficiency analysis completed.\n")
cat("Project directory:", project_dir, "\n")
cat("Rows after cleaning:\n")
print(dataset_summary)
cat("\nModel metrics:\n")
print(model_metrics)
