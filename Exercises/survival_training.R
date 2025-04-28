
install.packages("devtools")
devtools::install_github("ohdsi/CohortConstructor") # need github version for deathCohort function



library(CDMConnector)
library(CohortSurvival)
library(CohortCharacteristics)
library(CohortConstructor)
library(CodelistGenerator)



# You are doing some cutting edge research into three cancers.
# You have been asked to calculate the overall survival of a cancer stratfied by different demographics

# Databases
# Cancer 1 LUNG: 'synthea-lung_cancer-10k'

# Cancer 2 PROSTATE: 'synthea-veteran_prostate_cancer-10k'

# Cancer 3: BREAST: synthea-breast_cancer-10k'


# CDMConnector::requireEunomia("synthea-lung_cancer-10k")
# con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir("synthea-lung_cancer-10k"))
# 
# CDMConnector::requireEunomia("synthea-veteran_prostate_cancer-10k")
# con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir("synthea-veteran_prostate_cancer-10k"))

#get database
CDMConnector::requireEunomia("synthea-breast_cancer-10k")

#db connection
con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir("synthea-breast_cancer-10k"))

# create cdm
cdm <- CDMConnector::cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")

# get codelist for breast cancer (hint look in athena for Malignant tumor of breast)
bca_codelist <- getDescendants(
  cdm,
  conceptId = 4112853 
) # 278


# create a cohort of people with bca code and descendants (you need to name the list of codes otherwise it doesnt work)
# this is using cohortconstructor
cdm[["bca_cancer"]] <- conceptCohort(cdm,
                                     conceptSet = list(bca_cancer_codes = bca_codelist$concept_id),
                                     name = "bca_cancer",
                                     exit = "event_end_date",
                                     useSourceFields = FALSE,
                                     subsetCohort = NULL,
                                     subsetCohortId = NULL
)


# get counts
cohortCount(cdm[["bca_cancer"]])

#get outcome cohort for survival (i.e. death) - hint look at cohortconstructer for a handy function
cdm$death_cohort <- deathCohort(cdm, name = "death_cohort")

# counts of deaths in cohort
cohortCount(cdm[["death_cohort"]])


# basic survival
bca_death <- estimateSingleEventSurvival(cdm,
                                          targetCohortTable = "bca_cancer",
                                          outcomeCohortTable = "death_cohort"
)










