#### UNDER DEVELOPMENT! #######




install.packages("devtools")
devtools::install_github("ohdsi/CohortConstructor") # need github version for deathCohort function



library(CDMConnector)
library(CohortSurvival)
library(CohortCharacteristics)
library(CohortConstructor)
library(CodelistGenerator)
library(visOmopResults)
library(PatientProfiles)



# Databases
# 1: BREAST: synthea-breast_cancer-10k'
# 2: HEART: 'synthea-heart-10k'

dbName <- 'synthea-breast_cancer-10k'
#dbName <- 'synthea-heart-10k'

#get database
CDMConnector::requireEunomia(dbName)

#db connection
con <- duckdb::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir(dbName))

# create cdm
cdm <- CDMConnector::cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main", cdmName = dbName)


# # grabs the top conditions in the table
# cdm$condition_occurrence |>
#   dplyr::group_by(condition_concept_id) |>
#   dplyr::tally() |>
#   dplyr::inner_join(
#     cdm$concept |>
#       dplyr::select(condition_concept_id = "concept_id", "concept_name"),
#     by = "condition_concept_id"
#   ) |>
#   dplyr::collect() |>
#   dplyr::arrange(dplyr::desc(.data$n)) %>%
#   print(n = 40)


# condition_concept_id     n concept_name             
# <int> <dbl> <chr>                    
#   1               317576  1283 Coronary arteriosclerosis
# 2               381316   930 Cerebrovascular accident 
# 3               313217   791 Atrial fibrillation      
# 4               321042   514 Cardiac arrest           
# 5              4329847   508 Myocardial infarction    
# 6              4112853   278 Malignant tumor of breast

# some cancer treatments increase risk of CA >> could this be a compeating risk?

# get codelist for breast cancer 
bca_codelist <- getDescendants(
  cdm,
  conceptId = 4112853
) # 278

# export the codelists
# list(bca_cancer_codes = bca_codelist$concept_id) |>
#   omopgenerics::newCodelist() |>
#   omopgenerics::exportCodelist(path = here::here("concepts"), type = "csv")

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

# add age group to cohort

cdm[["bca_cancer"]] <- cdm[["bca_cancer"]] %>% 
  PatientProfiles::addDemographics(
    ageGroup = list(
      "age_group" =
        list(
          "0 to 49" = c(0, 49),
          "50 +" = c(50, Inf)
        )
      )
    )
  



#get outcome cohort for survival (i.e. death) - hint look at cohortconstructer for a handy function
cdm$death_cohort <- deathCohort(cdm, name = "death_cohort")

# counts of deaths in cohort
cohortCount(cdm[["death_cohort"]])


# basic survival
bca_death <- estimateSingleEventSurvival(cdm = cdm,
                                         targetCohortTable = "bca_cancer",
                                         outcomeCohortTable = "death_cohort",
                                         followUpDays = 1825,
                                         strata = list(c("age_group"),
                                                       c("sex")
            
                                         ))
                                         


tableSurvival(bca_death %>% filter(strata_name != "overall" &
                                     strata_name != "sex" ),
              timeScale = "days",
              times = c(365, 720, 1825))

# plot age groups
plotSurvival(bca_death %>% filter(strata_name != "overall" &
                                    strata_name != "sex" ), 
             riskTable = TRUE, 
             ribbon = FALSE,
             colour = "age_group",
             riskInterval = 180 )


# plot sex
plotSurvival(bca_death %>% filter(strata_name != "overall" &
                                    strata_name != "age_group" ), 
             riskTable = TRUE, 
             ribbon = FALSE,
             colour = "sex",
             riskInterval = 180 )






# export the codelists
# list(lca_cancer_codes = lca_codelist$concept_id) |>
#   omopgenerics::newCodelist() |>
#   omopgenerics::exportCodelist(path = here::here("concepts"), type = "csv")


# condition_concept_id     n concept_name             
# <int> <dbl> <chr>                    
#   1               317576  1249 Coronary arteriosclerosis
# 2               381316   976 Cerebrovascular accident 
# 3               313217   797 Atrial fibrillation      
# 4               321042   531 Cardiac arrest           
# 5              4329847   465 Myocardial infarction   

ca_heart_codelists <- getDescendants(
  
  cdm,
  conceptId = c(
    
    317576
    
  )
)




cdm[["ca"]] <- conceptCohort(cdm,
                                     conceptSet = list(ca_heart_codelists = ca_heart_codelists$concept_id),
                                     name = "ca",
                                     exit = "event_end_date",
                                     useSourceFields = FALSE,
                                     subsetCohort = NULL,
                                     subsetCohortId = NULL
)


# get counts
cohortCount(cdm[["ca"]])

# add age group to cohort

cdm[["ca"]] <- cdm[["ca"]] %>% 
  PatientProfiles::addDemographics(
    ageGroup = list(
      "age_group" =
        list(
          "0 to 59" = c(0, 59),
          "60 +" = c(60, Inf)
          
          
          
        )
    )
  )




#get outcome cohort for survival (i.e. death) - hint look at cohortconstructer for a handy function
cdm$death_cohort <- deathCohort(cdm, name = "death_cohort")


# counts of deaths in cohort
cohortCount(cdm[["death_cohort"]])


# basic survival
ca_death <- estimateSingleEventSurvival(cdm = cdm,
                                         targetCohortTable = "ca",
                                         outcomeCohortTable = "death_cohort",
                                         followUpDays = 3650,
                                         strata = list(c("age_group"),
                                                       c("sex"),
                                                       c("age_group", "sex")
                                                       
                                         ))



tableSurvival(ca_death %>% filter(strata_name != "overall" &
                                     strata_name != "sex" ),
              timeScale = "days",
              times = c(365, 720, 1825, 3650))

# plot age groups
plotSurvival(ca_death %>% filter(strata_name != "overall" &
                                    strata_name != "sex" ), 
             riskTable = TRUE, 
             ribbon = FALSE,
             colour = "age_group",
             riskInterval = 360 )


# plot sex
plotSurvival(ca_death %>% filter(strata_name != "overall" &
                                    strata_name != "age_group" ), 
             riskTable = TRUE, 
             ribbon = FALSE,
             colour = "sex",
             riskInterval = 360 )



#ca to MI
mi_heart_codelists <- getDescendants(
  
  cdm,
  conceptId = c(
    4329847
  )
)

# Kaplan-Meier survival analysis to estimate the probability that patients with coronary arteriosclerosis remain free from a heart attack over time

cdm[["mi"]] <- conceptCohort(cdm,
                             conceptSet = list(mi_heart_codelists = mi_heart_codelists$concept_id),
                             name = "mi",
                             exit = "event_end_date",
                             useSourceFields = FALSE,
                             subsetCohort = NULL,
                             subsetCohortId = NULL
)



ca_mi <- estimateSingleEventSurvival(cdm = cdm,
                                        targetCohortTable = "ca",
                                        outcomeCohortTable = "mi",
                                        followUpDays = 3650,
                                        strata = list(c("age_group"),
                                                      c("sex"),
                                                      c("age_group", "sex"))
                                                      
                                        )




tableSurvival(ca_mi %>% filter(strata_name != "overall" &
                                    strata_name != "sex" ),
              timeScale = "days",
              times = c(365, 720, 1825, 3650))


tableSurvival(ca_mi %>% filter(strata_name == "overall"  ),
              timeScale = "days",
              times = c(365, 720, 1825, 3650))

tableSurvival(ca_mi %>% filter(strata_name != "overall" &
                                 strata_name != "age_group" ),
              timeScale = "days",
              times = c(365, 720, 1825, 3650))



# plot age groups
plotSurvival(ca_mi %>% filter(strata_name != "overall" &
                                   strata_name != "sex" ), 
             riskTable = TRUE, 
             ribbon = FALSE,
             colour = "age_group",
             riskInterval = 365 )


# plot sex
plotSurvival(ca_mi %>% filter(strata_name != "overall" &
                                   strata_name != "age_group" ), 
             riskTable = TRUE, 
             ribbon = FALSE,
             colour = "sex",
             riskInterval = 360 )




# competing risk

"We estimated the probability of heart attack following atherosclerosis diagnosis, 
accounting for death as a competing risk. The 5-year cumulative incidence of heart
attack was X%, and the competing risk of death without heart attack was Y%."

"After accounting for death as a competing risk, the 10-year cumulative incidence
of heart attack among patients with coronary atherosclerosis was 24%. An additional
18% died without experiencing a heart attack. These findings highlight the importance
of managing both cardiovascular and overall health risks in this population."

ca_mi_death <- estimateCompetingRiskSurvival(cdm,
                                             targetCohortTable = "ca",
                                             outcomeCohortTable = "mi",
                                             competingOutcomeCohortTable = "death_cohort",
                                             followUpDays = 3650,
                                             strata = list(c("age_group"),
                                                           c("sex"),
                                                           c("age_group", "sex"))
) 



plotSurvival(ca_mi_death %>% filter(strata_name == "sex" ), cumulativeFailure = TRUE,
             colour = c("variable", "sex"))


tableSurvival(ca_mi_death %>% filter(strata_name == "sex" )) 


