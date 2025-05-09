#### Cohort Survival #######

# Below are the snippets of code that will help perform survival analysis with tasks

# You should have already worked your way through the CodeToRun.R file and have your main cohorts instantiated (breast cancer, heart attack etc)

# 1: add in demographics ------------- 
# (*tip we have small databases so dont go crazy)
# stuck filling code for age bands? look at AddAge to see how the code is structured:
# https://darwin-eu.github.io/PatientProfiles/articles/demographics.html

cdm[["..."]] <- cdm[["..."]] %>% 
  addDemographics(
    ageGroup = list(
      "age_group" =
        list(
          "add age group bands here"
        )
    ),
    name = "..." # preferably use the same to prevent errors in the future
  )

# 2: get your outcome cohorts ----------------
# Choices what is your outcome? 1) death or 2) another condition - you decide :)

# if you are choosing death you need to create it
# if this code does not work run the function on line 80
cdm$death_cohort <- deathCohort(cdm, name = "death_cohort")


# 3: carry out survival -------------------------
# have a think about different settings and the impact of these
# ?? estimateSingleEventSurvival
survival_analysis <- estimateSingleEventSurvival(cdm = cdm,
                                                 targetCohortTable = "...",
                                                 outcomeCohortTable = "...",
                                                 targetCohortId = "...", # run on all index cohorts or select one?
                                                 followUpDays = 1825, # or choose your own
                                                 strata = list(c("age_group"),
                                                               c("sex")
                                                 ))

# 4: tablulate results ---------------------

# you can create a summary table based on your results
# if you want to just tabulate certain results you can filter out the results within the functions like in the example below
# we are only interested in age stratifications
# have a think of the survival probabilities and at what time you want to focus on

survival_analysis |> 
  filterStrata(age_group != "overall") |>
  tableSurvival(timeScale = "days",
                times = c("...")) # add in some times e.g 365, 720 etc

# 5: Create plots ---------------------------
# again you can filter your results to plot the ones you are interested in
# are there differences in sex and age?
survival_analysis |> 
  filterStrata(age_group != "overall") |>
  plotSurvival(riskTable = TRUE, # do you want the risk table underneath the plot?
               ribbon = FALSE, # do you want the confidence intervals?
               colour = "age_group",
               riskInterval = 180 )

# 6: put the results into a powerpoint














# creating a death cohort function
deathCohort <- function(
    cdm,
    name,
    subsetCohort = NULL,
    subsetCohortId = NULL){
  
  name <- omopgenerics::validateNameArgument(name, validation = "warning")
  cdm <- omopgenerics::validateCdmArgument(cdm)
  omopgenerics::assertCharacter(subsetCohort, length = 1, null = TRUE)
  if (!is.null(subsetCohort)) {
    omopgenerics::validateCohortArgument(cdm[[subsetCohort]])
    omopgenerics::validateCohortIdArgument(subsetCohortId,
                                           cdm[[subsetCohort]],
                                           validation = "error")
  }
  
  if (is.null(subsetCohort)) {
    subsetCohort <- as.character(NA)
  }
  if (is.null(subsetCohortId)) {
    subsetCohortId <- as.numeric(NA)
  }
  cohortSetRef <- dplyr::tibble(
    "cohort_definition_id" = 1L,
    "cohort_name" = "death_cohort",
    "subset_cohort_table" = subsetCohort,
    "subset_cohort_id" = subsetCohortId
  )
  
  cdm[[name]] <-  cdm$death |>
    dplyr::mutate(cohort_definition_id = 1L) |>
    dplyr::select("cohort_definition_id",
                  "subject_id" = "person_id",
                  "cohort_start_date" = "death_date",
                  "cohort_end_date" ="death_date") |>
    dplyr::compute(temporary = FALSE, name = name)
  
  cdm[[name]] <- cdm[[name]] |>
    omopgenerics::newCohortTable(cohortSetRef = cohortSetRef,
                                 .softValidation = TRUE)
  
  cdm[[name]] <-  cdm[[name]] |>
    PatientProfiles::filterInObservation(indexDate = "cohort_start_date") |>
    dplyr::compute(temporary = FALSE, name = name) |>
    omopgenerics::recordCohortAttrition("Death record in observation")
  
  if (!is.na(subsetCohort)){
    if (!is.na(subsetCohortId)){
      cdm[[name]] <- cdm[[name]] |>
        dplyr::inner_join(cdm[[subsetCohort]] |>
                            dplyr::filter(.data$cohort_definition_id %in% subsetCohortId) |>
                            dplyr::select("subject_id"),
                          by = c("subject_id")) |>
        dplyr::compute(
          name = name,
          temporary = FALSE,
          overwrite = TRUE) |>
        omopgenerics::recordCohortAttrition("In subset cohort")
    }else{
      cdm[[name]] <- cdm[[name]] |>
        dplyr::inner_join(cdm[[subsetCohort]] |>
                            dplyr::select("subject_id"),
                          by = c("subject_id")) |>
        dplyr::compute(
          name = name,
          temporary = FALSE,
          overwrite = TRUE) |>
        omopgenerics::recordCohortAttrition("In subset cohort")
    }
  }
  
  cdm[[name]] <- cdm[[name]] |>
    dplyr::group_by(.data$subject_id) |>
    dbplyr::window_order(.data$cohort_start_date) |>
    dplyr::filter(dplyr::row_number()==1) |>
    dplyr::select(
      "cohort_definition_id", "subject_id", "cohort_start_date",
      "cohort_end_date"
    ) |>
    dplyr::ungroup() |>
    dplyr::compute(
      name = name,
      temporary = FALSE,
      overwrite = TRUE) |>
    omopgenerics::recordCohortAttrition("First death record")
  
  cdm[[name]] <- omopgenerics::newCohortTable(table = cdm[[name]])
  cli::cli_inform(c("v" = "Cohort {.strong {name}} created."))
  
  return(cdm[[name]])
}

