# install and load packages ----
# Let's install the needed packages
install.packages("CDMConnector") # 2.0.0
install.packages("omopgenerics") # 1.1.1
install.packages("CohortSurvival") # 1.0.1
install.packages("CohortConstructor") # 0.4.0
install.packages("CodelistGenerator") # 3.5.0
install.packages("visOmopResults") # 1.0.2
install.packages("PatientProfiles") # 1.3.1
install.packages("ggplot2") # Any
install.packages("plotly") # Any
install.packages("reactable") # Any
install.packages("gt") # Any
install.packages("duckdb") # Any
install.packages("pak") # Any

# In this practical, we will test the new release of CohortCharacteristics.
# We'll install then the GitHub version.
library(pak)
pkg_install("darwin-eu/CohortCharacteristics@release_100")

# Note: Typically, you'd install the CRAN version using:
# install.packages("CohortCharacteristics")

# call the packages in the library
library(duckdb)
library(CDMConnector)
library(CohortSurvival)
library(CohortCharacteristics)
library(CohortConstructor)
library(CodelistGenerator)
library(visOmopResults)
library(PatientProfiles)
library(omopgenerics)
library(dplyr)
library(here)

# create the cdm object ----

# Choose one of the synthetic datasets to create the cdm object
# dbName <- 'synthea-breast_cancer-10k'
# dbName <- 'synthea-heart-10k'

# download the dataset
Sys.setenv("EUNOMIA_DATA_FOLDER" = here())
downloadEunomiaData(datasetName = dbName)

# create connection
con <- dbConnect(drv = duckdb(dbdir = eunomiaDir(datasetName = dbName)))

# create cdm object
cdm <- cdmFromCon(con = con,
                  cdmSchema = "main", 
                  writeSchema = "main",
                  cdmName = dbName)

# let's explore a bit the database ----
# top conditions in the table
cdm$condition_occurrence |>
  group_by(condition_concept_id) |>
  tally() |>
  inner_join(
    cdm$concept |>
      select(condition_concept_id = "concept_id", "concept_name"),
    by = "condition_concept_id"
  ) |>
  collect() |>
  arrange(desc(n)) 

# top medications in the table
cdm$drug_exposure |>
  group_by(drug_concept_id) |>
  tally() |>
  inner_join(
    cdm$concept |>
      select(drug_concept_id = "concept_id", "concept_name"),
    by = "drug_concept_id"
  ) |>
  collect() |>
  arrange(desc(n)) 

# cancer codelists ----
cancer <- importCodelist(path = here("codelists", "index"), type = "csv")
cancer
# if you are interested in how we got these codelists see the code in:
# `codelists/getCodelists.R` 

# cancer cohorts ----
cdm$index_cohorts <- conceptCohort(cdm = cdm,
                                   conceptSet = cancer,
                                   name = "index_cohorts",
                                   exit = "event_end_date",
                                   useSourceFields = FALSE,
                                   subsetCohort = NULL,
                                   subsetCohortId = NULL)

# the cohort
cdm$index_cohorts

# settings
settings(cdm$index_cohorts)

# cohortCount
cohortCount(cdm$index_cohorts)

# attrition
attrition(cdm$index_cohorts)

# Next steps ----
# Now we are ready for the next steps:
# 1) Characterisation: characteristics_exercises.R
# 2) Survival: survival_exercises.R