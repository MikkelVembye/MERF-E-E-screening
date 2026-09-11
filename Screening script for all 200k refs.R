library(AIscreenR)
library(tidyverse)
library(future)
library(furrr)

dat_185k <- readRDS("all studies data/long_term_190_dat_minus_irrelevant_protocol.RDS")

ris_file_names <- list.files(path = "all studies data/", pattern = "*.txt", full.names = TRUE)

dat_21k <- 
  map(
    ris_file_names,
    ~ read_ris_to_dataframe(.x) 
  ) |> 
  list_rbind()
  
long_term_all_dat <- bind_rows(dat_185k, dat_21k)
saveRDS(long_term_all_dat, "all studies data/long_term_200k_dat.RDS")


prompt_final <- "
You are screening records to identify reports potentially belonging to randomized controlled trials of childhood interventions that measured cognitive and/or social-emotional skills at the end of the intervention and subsequently assessed outcomes in adulthood.

Classify each record as INCLUDE or EXCLUDE according to the criteria below. The purpose of title-and-abstract screening is to achieve very high recall. Therefore, classify a record as INCLUDE whenever eligibility is plausible or information is missing, incomplete, or unclear. This includes studies for which it is unclear whether participants or other units were randomly assigned. Classify a record as EXCLUDE only when the available information clearly demonstrates that it is ineligible. Studies explicitly described as quasi-experimental, natural experiments, or otherwise nonrandomized should be classified as EXCLUDE.

A record should be classified as INCLUDE if it potentially concerns a randomized controlled trial meeting all three criteria:

1. Intervention before high school

The intervention affected children before they entered high school, and the intervention ended before high school entry.

Eligible interventions may have been delivered during:

* early childhood;
* preschool, prekindergarten, or kindergarten;
* primary or elementary school;
* middle school or lower-secondary school, provided that the intervention ended before participants entered high school; or
* another period clearly occurring before high school entry.

The intervention does not need to have been delivered directly to the children. For example, interventions targeting parents, caregivers, teachers, classrooms, or schools may be eligible if they were intended to affect children before high school entry.

Interpret “high school” according to the educational system in the country where the intervention occurred. If participants’ school level or whether the intervention ended before high school is unclear, classify the record as INCLUDE.

Classify the record as EXCLUDE if it is clear that the intervention began or continued after participants entered high school or upper-secondary education.

2. Cognitive or social-emotional outcomes at intervention end

The trial reported, or may have reported, quantitative intervention impacts on at least one cognitive or social-emotional skill at or near the end of the intervention.

Cognitive outcomes include, but are not limited to:

* general cognitive ability or intelligence;
* executive functioning;
* attention, memory, inhibitory control, or cognitive flexibility;
* language or communication skills;
* literacy, reading, writing, or vocabulary;
* mathematics, numeracy, science, or other academic skills;
* school readiness; and
* academic achievement or performance.

Social-emotional outcomes include, but are not limited to:

* social skills or social competence;
* emotional skills, emotional regulation, or emotional competence;
* self-control, self-regulation, persistence, or motivation;
* self-efficacy, self-esteem, or self-concept;
* interpersonal or relationship skills;
* prosocial behavior, aggression, conduct, or externalizing behavior;
* internalizing symptoms, psychological adjustment, or mental health;
* behavior problems; and
* related measures of social or emotional development.

The relevant posttest or endline results may be reported in the current record or in another publication from the same trial. Do not exclude an adult follow-up report merely because its title or abstract does not mention the outcomes measured at the end of the original intervention. If it is unclear whether cognitive or social-emotional outcomes were assessed at intervention end, classify the record as INCLUDE.

Classify the record as EXCLUDE only if it is clear that the trial did not measure any cognitive or social-emotional outcomes at or near intervention end.

3. Outcomes in adulthood

The trial reported, or the record may concern, quantitative intervention outcomes measured when participants:

* were 18 years of age or older; or
* had completed or progressed beyond grade 12, high school, or equivalent upper-secondary education, even if their exact age is not reported.

Any outcome measured in adulthood is eligible, including, but not limited to:

* educational attainment or postsecondary education;
* employment, earnings, income, or welfare receipt;
* physical health or health behavior;
* mental health or psychological well-being;
* substance use;
* crime, arrests, incarceration, or other justice-system outcomes;
* relationships, marriage, fertility, or parenting;
* housing or socioeconomic circumstances;
* mortality; and
* cognitive, social, emotional, or behavioral outcomes.

Adult outcomes may be based on participant assessments, surveys, administrative records, registers, or other quantitative data sources.

Classify the record as EXCLUDE if it is clear that all reported follow-up outcomes were measured before age 18 and no outcomes were measured after grade 12 or the equivalent. If participants’ exact age or educational stage at follow-up is unclear, classify the record as INCLUDE.

Additional decision rules

* Include primary reports, follow-up reports, secondary analyses, and linked administrative-data studies if they may report eligible results from an eligible randomized trial.
* Include a record if it may be a companion publication or follow-up report from an eligible trial, even if the record does not restate the trial’s randomization procedure or original posttest outcomes.
* Do not require the current record itself to report both the end-of-intervention outcomes and adult outcomes if these may be reported across multiple publications from the same trial.
* If random assignment is not mentioned and the study design is unclear, classify the record as INCLUDE.
* Classify the record as EXCLUDE if it is explicitly described as being based exclusively on a nonrandomized design, including a quasi-experiment or natural experiment.
* Classify reviews, commentaries, editorials, study protocols, and prospective analysis plans as EXCLUDE unless they also report original quantitative results from an eligible trial.
* Do not exclude a record merely because the abstract provides limited information.
* Do not make an exclusion based only on assumptions about participants’ ages, school levels, study design, or outcomes.

Final classification

Return INCLUDE if the record clearly meets the criteria or could plausibly meet them based on the available information.

Return EXCLUDE only if the record clearly fails at least one criterion.

Provide only one classification: INCLUDE or EXCLUDE.
"

dat1 <- 