# ---------------------------------------------------------
# NHANES 2017-2018 (cycle "J") data import
# Cohort with: age, sex, race, BMI, diabetes status, hypertension
# ---------------------------------------------------------

install.packages("nhanesA")  # uncomment if not yet installed
install.packages("dplyr")

library(nhanesA)
library(dplyr)

# --- 1. Pull the relevant tables -----------------------------------------
# DEMO_J = Demographics
# BMX_J  = Body Measures (includes BMI)
# DIQ_J  = Diabetes questionnaire
# BPQ_J  = Blood Pressure & Cholesterol questionnaire

demo <- nhanes("DEMO_J")
bmx  <- nhanes("BMX_J")
diq  <- nhanes("DIQ_J")
bpq  <- nhanes("BPQ_J")

# --- 2. Select just the columns we need -----------------------------------
#age, gender, ethnicity
demo_sub <- demo %>%
  dplyr::select(SEQN, RIDAGEYR, RIAGENDR, RIDRETH3)

#bmi
bmx_sub <- bmx %>%
  dplyr::select(SEQN, BMXBMI)

#diabetes status
diq_sub <- diq %>%
  dplyr::select(SEQN, DIQ010)

#hypertension
bpq_sub <- bpq %>%
  dplyr::select(SEQN, BPQ020)

# --- 3. Merge into one cohort dataset -------------------------------------
cohort <- demo_sub %>%
  left_join(bmx_sub, by = "SEQN") %>%
  left_join(diq_sub, by = "SEQN") %>%
  left_join(bpq_sub, by = "SEQN")

# --- 4. Recode into readable labels ---------------------------------------
cohort <- cohort %>%
  rename(
    id     = SEQN,
    age    = RIDAGEYR,
    sex    = RIAGENDR,
    race   = RIDRETH3,
    BMI    = BMXBMI,
    Diabetes = DIQ010,
    Hypertension = BPQ020
  ) %>%
  dplyr::select(id, age, sex, race, BMI, Diabetes, Hypertension)

# --- 5. Quick look ----------------------------------------------------------
str(cohort)
head(cohort)
summary(cohort)

# ---------------------------------------------------------
# 6. Quick descriptive plots
# ---------------------------------------------------------
install.packages("ggplot2")  # uncomment if not yet installed
library(ggplot2)

# --- Age: histogram ---------------------------------------------------------
ggplot(cohort, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(
    title = "Age Distribution of Cohort",
    x = "Age (years)",
    y = "Count"
  ) +
  theme_minimal()

# --- Sex: bar plot -----------------------------------------------------------
ggplot(cohort %>% filter(!is.na(sex)), aes(x = sex, fill = sex)) +
  geom_bar() +
  labs(
    title = "Sex Distribution of Cohort",
    x = "Sex",
    y = "Count"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# --- Race: bar plot -----------------------------------------------------------
ggplot(cohort %>% filter(!is.na(race)), aes(x = race, fill = race)) +
  geom_bar() +
  labs(
    title = "Race/Ethnicity Distribution of Cohort",
    x = "Race/Ethnicity",
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 40, hjust = 1)  # rotate labels so they don't overlap
  )
