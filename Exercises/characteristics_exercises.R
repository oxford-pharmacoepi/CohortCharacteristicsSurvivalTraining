#### Cohort Characteristics ####

# We have created the index cohorts let's now characterise them

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

# use the export button (top of thr viewer panel) to save a png

# if you are familiar with the require functions of CohortConstructor
# https://ohdsi.github.io/CohortConstructor/reference/index.html#apply-cohort-table-related-requirements
# you can try to add some requirements and see how the result impacts your attrition

# 3. Overlap ----
overlap <- summariseCohortOverlap(cdm[["..."]])

# lets plot the result
plotCohortOverlap(overlap)

# play with the argument uniqueCombinations = TRUE/FALSE
# which plot looks nicer?

# 4. Timing ----
timing <- summariseCohortTiming(cdm[["..."]])

# lets create a box plot first
plotCohortTiming(timing, plotType = "...")

# lets now see how a density plot looks like
plotCohortTiming(timing, plotType = "...")

# which plot is more informative?
# play with the timeScale argument and create the plot in days and years.

# 5. Table one ----
# We want to include in the characterisation:
# - Demographics
# - Median number of visits in the prior year ([-365, 0])
# - Medications in the prior year ([-365, 0]) use the codelist defined in `codelists/medications`

medications <- importCodelist(path = "...", type = "...")

characterisation <- cdm[["..."]] |>
  summariseCharacteristics(
    counts = "...",
    demographics = "...",
    tableIntersectCount = list(
      tableName = "...", window = "..."
    ),
    conceptIntersectFlag = list(
      conceptSet = "...", window = "..."
    )
  )

# create a gt table
characterisation |>
  tableCharacteristics()

# customise the table a bit, eliminate variables you are not interested in,
# eliminate not relevant cohorts, maybe we can add some strata? try to make it
# interesting

# plot age density by cohort (colour) note this will only work if you installed
# the github version of CohortCharacteristics
# note that if density is not added in estimates then you wont be able to plot 
# it, can you manage to get the plot?
characterisation |>
  filter(variable_name == "...") |>
  plotCharacteristics(
    plotType = "...", 
    colour = "..."
  )

# is the age distribution for both cohorts similar?

# 6. Large scale characterisation ----
# lets use large scale characterisation for 
# event: condition_occurrence, procedure_occurrence
# episode: drug_exposure
# lets stratify the result by two age groups [0 to 49] and >=50
# lets define a couple of windows, you decide which ones
lsc <- cdm[["..."]] |>
  addAge(ageGroup = "...") |>
  summariseLargeScaleCharacteristics(
    strata = "...", 
    window = "...", 
    eventInWindow = "...", 
    episodeInWindow = "...", 
    minimumFrequency = "..."
  )

# lets explore the top concepts
tableTopLargeScaleCharacteristics(lsc)

# ouch the table is too big are you able to subset to only 4 columns, choose the
# ones more interesting for you :)
lsc |>
  filterSettings(table_name %in% "...") |>
  filterGroup(cohort_name %in% "...") |>
  filterStrata(age_group %in% "...") |>
  filter(variable_level %in% "...") |>
  tableTopLargeScaleCharacteristics()

# lets create a reactable table to explore the drug_exposure results
# subsetset the results to only drug_exposure
lscDrugs <- lsc |>
  filterSettings(table_name == "...")

tableLargeScaleCharacteristics(lscDrugs)

# lets now compare the results by window
tableLargeScaleCharacteristics(lscDrugs, 
                               compareBy = "variable_level")

# would you be able to compare by cohort_name?
tableLargeScaleCharacteristics(lscDrugs, 
                               compareBy = "...")

# would you be able to set a reference to include SMD values in the table?
tableLargeScaleCharacteristics(lscDrugs, 
                               compareBy = "...", 
                               smdReference = "...")

# is this table useful? we are always happy to recieve feedback from it

# lets see the same visualisation with a plot
# lets do it with only conditions from one window and one cohort and lets 
# compare the different age groups that we have defined
lscConditions <- lsc |>
  filterSettings(table_name == "...") |>
  filterGroup(cohort_name == "...") |>
  filter(variable_level == "...") 

plotComparedLargeScaleCharacteristics(lscConditions, 
                                      colour = "age_group", 
                                      reference = "overall")

# lets make it interactive :)
plotComparedLargeScaleCharacteristics(lscConditions, 
                                      colour = "age_group", 
                                      reference = "overall") |>
  ggplotly()

# are the new plots and tables for large scale characterisation visualisation 
# useful?
# we are happy to receive feedback! :)

# 7. What time is is? Report time!!!!! ----
# if you have time try to build a mini presentation (maybe using nice quarto? or 
# a boring PowerPoint) with the main learnings and charcateristics of your 
# cohorts of interest.
