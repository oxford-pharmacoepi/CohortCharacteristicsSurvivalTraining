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














