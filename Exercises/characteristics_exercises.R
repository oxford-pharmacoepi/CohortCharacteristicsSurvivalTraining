#### Cohort Characteristics ####

# We have created the cancer cohorts let's now characterise them

# 1. Counts ----
counts <- summariseCohortCount(cdm[["..."]])

# lets create a table
tableCohortCount(counts)

# 2. Attrition ----
attrition <- summariseCohortAttrition(cdm[["..."]])

# lets plot a digram of only one of the cohorts
attrition |>
  filterGroup(cohort_name == "...") |>
  plotCohortAttrition()

# 3. Overlap ----
overlap <- summariseCohortOverlap(cdm[["..."]])

# lets plot the result
plotCohortOverlap(overlap)

# 4. Timing ----
timing <- summariseCohortTiming(cdm[["..."]])

# lets create a box plot first
plotCohortTiming(timing, plotType = "...")

# lets now see how a density plot looks like
plotCohortTiming(timing, plotType = "...")

# which one is nicer? :)

# 5. Table one ----
# We want to include in the characterisation:
# - Demographics
# - Median number of visits in the prior year ([-365, 0])
# - Medications in the prior year ([-365, 0]) use the codelist defined in `codelists/medications`
characterisation <- cdm[["..."]] |>
  summariseCharacteristics(
    counts = "...",
    demographics = "...",
    tableIntersectCount = list(
      tableName = "...", window = c(...)
    ),
    conceptIntersectFlag = list(
      conceptSet = "...", window = c(...)
    )
  )

# create a gt table
characterisation |>
  tableCharacteristics()

# plot age density by cohort (colour)
characterisation |>
  filter(variable_name == "...") |>
  plotCharacteristics(
    plotType = "...", 
    colour = "..."
  )

# 6. Large scale characterisation ----
# lets use large scale characterisation for 
# event: condition_occurrence, procedure_occurrence, device_exposure, measurement, observation
# episode: drug_exposure
# lets stratify the result by two age groups [0 to 49] and >=50
# lets define a couple of windows
lsc <- cdm[["..."]] |>
  addAge(ageName = list("...")) |>
  summariseLargeScaleCharacteristics(
    strata = "...", 
    window = "...", 
    eventInWindow = "...", 
    episodeInWindow = "...", 
    minimumFrequency = "..."
  )

# lets explore the top concepts
tableTopLargeScaleCharacteristics(lsc)

# lets create a reactable table to compare the drug_exposure results by window
tableComparedLargeScaleCharacteristics(lsc, ...)

# lets see the same visualisation with an interactive plot
plotComparedLargeScaleCharacteristics(lsc, ...)
