library(omopgenerics)
library(CodelistGenerator)
library(here)

# getting cancer codelists ----
# how to we got the codelists you are using for your study
# in the exercises you are getting the codelists by reading in a csv file 
# however the code below shows how we got to that step for your reference

# get codelist for breast cancer 
bca_codelist <- getDescendants(cdm = cdm, conceptId = 4112853) 

# get codelist for Coronary arteriosclerosis
ca_heart_codelists <- getDescendants(cdm = cdm, conceptId = 317576)

# heart attack (myocardial infarction)
mi_heart_codelists <- getDescendants(cdm = cdm, conceptId = 4329847)

# export codelists
list(
  breat_cancer = bca_codelist$concept_id,
  coronary_arteriosclerosis = ca_heart_codelists$concept_id,
  heart_attack = mi_heart_codelists$concept_id
) |>
  newCodelist() |>
  exportCodelist(path = here("codelists", "cancer"), type = "csv")

# getting medications codelists ----
medications <- getATCCodes(cdm = cdm, level = "ATC 1st", nameStyle = "{concept_name}")
exportCodelist(x = medications, path = here("codelists", "medications"), type = "csv")
