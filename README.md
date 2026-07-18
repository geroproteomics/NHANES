# NHANES
Tutorial for data import and wrangling of NHANES cohort data

## Overview  
The National Health and Nutrition Examination Survey (NHANES) is a program of studies run by the CDC's National Center for Health Statistics, designed to assess the health and nutritional status of adults and children in the United States. It's unique in combining household interviews (demographics, health history, lifestyle questionnaires) with a physical examination component conducted in mobile exam centers (body measurements, blood pressure, lab tests on blood and urine samples). NHANES uses a complex, multistage probability sampling design, oversampling certain groups (e.g., older adults, specific racial/ethnic groups) to ensure reliable estimates — which is why analyses intended to generalize to the U.S. population need to incorporate the survey weights, rather than treating the data as a simple random sample. Data are released in continuous two-year cycles (e.g., 2017–2018), and for this project we're using the 2017–2018 cycle to build a simple cohort with basic demographics (age, sex, race/ethnicity) and health parameters (BMI, diabetes status, hypertension).


## Install packages 
Packages are necessary for importing data from NHANES.

install.packages("nhanesA")
install.packages("dplyr")
install.packages("ggplot2")  # uncomment if not yet installed

After installation, initialize the packages.
library(nhanesA)
library(dplyr)
library(ggplot2)

## Data import and wrangling
The data must be imported into your R session, and wrangled into a usable format prior to visualization.

### --- 1. Pull the relevant tables -----------------------------------------
#### DEMO_J = Demographics
#### BMX_J  = Body Measures (includes BMI)
#### DIQ_J  = Diabetes questionnaire
#### BPQ_J  = Blood Pressure & Cholesterol questionnaire

demo <- nhanes("DEMO_J")
bmx  <- nhanes("BMX_J")
diq  <- nhanes("DIQ_J")
bpq  <- nhanes("BPQ_J")

### --- 2. Select just the columns we need -----------------------------------
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

### --- 3. Merge into one cohort dataset -------------------------------------
cohort <- demo_sub %>%
  left_join(bmx_sub, by = "SEQN") %>%
  left_join(diq_sub, by = "SEQN") %>%
  left_join(bpq_sub, by = "SEQN")

### --- 4. Recode into readable labels ---------------------------------------
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

### --- 5. Quick look ----------------------------------------------------------
Use head(cohort) to see your data.
Your data should look something like below:

| ID             | age         | sex             |     race                |         BMI        |   Diabetes         |  Hypertension     |
|----------------|-------------|-----------------|-------------------------|--------------------|--------------------|-------------------|
| 1              | 58          | Male            |   White                 |     25.6           |  Yes               | No                |
| 2              | 26          | Female          |   Non-Hispanic Asian    |     31.2           |  No                | No                |
| 3              | 19          | Male            |   White                 |     19.8           |  Yes               | Yes               |
| 4              | 24          | Fale            |   White                 |     21.3           |  No                | No                |

### 6. Quick descriptive plots

#### --- Age: histogram ---------------------------------------------------------
ggplot(cohort, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(
    title = "Age Distribution of Cohort",
    x = "Age (years)",
    y = "Count"
  ) +
  theme_minimal()

  Your plot should look like the following: 
  <p align="center">
  <img src="images/Example_ivsum_SNC.JPG" alt="Example Image of Sums of Selected Features for Each Parameter" width="500">
</p>

#### --- Sex: bar plot -----------------------------------------------------------
ggplot(cohort %>% filter(!is.na(sex)), aes(x = sex, fill = sex)) +
  geom_bar() +
  labs(
    title = "Sex Distribution of Cohort",
    x = "Sex",
    y = "Count"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

    Your plot should look like the following: 
  <p align="center">
  <img src="images/Example_ivsum_SNC.JPG" alt="Example Image of Sums of Selected Features for Each Parameter" width="500">
</p>

#### --- Race: bar plot -----------------------------------------------------------
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

    Your plot should look like the following: 
  <p align="center">
  <img src="images/Example_ivsum_SNC.JPG" alt="Example Image of Sums of Selected Features for Each Parameter" width="500">
</p>
 

