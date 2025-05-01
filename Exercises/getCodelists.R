# getting codelists -----------------------

# how to we got the codelists you are using for your study

# in the exercises you are getting the codelists by reading in a csv file 
# however the code below shows how we got to that step for your reference



# breast cancer ----------

# get codelist for breast cancer 
bca_codelist <- getDescendants(
  cdm,
  conceptId = 4112853
) 

# export the codelists 
list(bca_cancer_codes = bca_codelist$concept_id) |>
  omopgenerics::newCodelist() |>
  omopgenerics::exportCodelist(path = here::here("concepts"), type = "csv")



# Coronary arteriosclerosis ----------
# get codelist for Coronary arteriosclerosis
ca_heart_codelists <- getDescendants(
  cdm,
  conceptId = c(
    317576
  )
)

list(ca_heart_codelists = ca_heart_codelists$concept_id) |>
  omopgenerics::newCodelist() |>
  omopgenerics::exportCodelist(path = here::here("concepts"), type = "csv")


# heart attack (myocardial infarction) ------
mi_heart_codelists <- getDescendants(
  cdm,
  conceptId = c(
    4329847
  )
)

list(mi_heart_codelists = mi_heart_codelists$concept_id) |>
  omopgenerics::newCodelist() |>
  omopgenerics::exportCodelist(path = here::here("concepts"), type = "csv")


