# get the packages you need using renv
renv::activate()
renv::restore()

# call the packages in the library
library(CDMConnector)
library(CohortSurvival)
library(CohortCharacteristics)
library(CohortConstructor)
library(CodelistGenerator)
library(visOmopResults)
library(PatientProfiles)


# choose database --------
dbName <- 'synthea-breast_cancer-10k'
#dbName <- 'synthea-heart-10k'

#get database ---------
CDMConnector::requireEunomia(dbName)

#get db connection ----------
con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir(dbName))

# create cdm -------------
cdm <- CDMConnector::cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main", cdmName = dbName)

# top conditions in the table ---------
cdm$condition_occurrence |>
  dplyr::group_by(condition_concept_id) |>
  dplyr::tally() |>
  dplyr::inner_join(
    cdm$concept |>
      dplyr::select(condition_concept_id = "concept_id", "concept_name"),
    by = "condition_concept_id"
  ) |>
  dplyr::collect() |>
  dplyr::arrange(dplyr::desc(.data$n)) 

# import codelists --------------
omopgenerics::importCodelist(path = here::here("concepts"), type = "csv")
# if you are interested in how we got these codelists please see getCodelists.R in the Exercises folder

# instantiate codelists in cdm --------------
cdm[["bca_cancer"]] <- conceptCohort(cdm,
                                     conceptSet = list(bca_cancer_codes = bca_codelist$concept_id),
                                     name = "bca_cancer",
                                     exit = "event_end_date",
                                     useSourceFields = FALSE,
                                     subsetCohort = NULL,
                                     subsetCohortId = NULL
)


cdm[["ca"]] <- conceptCohort(cdm,
                             conceptSet = list(ca_heart_codelists = ca_heart_codelists$concept_id),
                             name = "ca",
                             exit = "event_end_date",
                             useSourceFields = FALSE,
                             subsetCohort = NULL,
                             subsetCohortId = NULL
)


cdm[["heart_attack"]] <- conceptCohort(cdm,
                             conceptSet = list(mi_heart_codelists = mi_heart_codelists$concept_id),
                             name = "heart_attack",
                             exit = "event_end_date",
                             useSourceFields = FALSE,
                             subsetCohort = NULL,
                             subsetCohortId = NULL
)

# you are ready for the next steps of the excercises characterisation and survival!