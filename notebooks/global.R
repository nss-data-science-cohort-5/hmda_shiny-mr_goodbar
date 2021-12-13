library(ggplot2)
library(dplyr)

derivedrace <- c("American Indian or Alaska Native" = "American Indian or Alaska Native",
                 "Asian" = "Asian",
                 "Black or African American" = "Black or African American",
                 "Native Hawaiian or Other Pacific Islander" = "Native Hawaiian or Other Pacific Islander",
                 "White" = "White",
                 "2 or more minority races" = "2 or more minority races",
                 "Joint" = "Joint",
                 "Free Form Text Only" = "Free Form Text Only",
                 "Race Not Available" = "Race Not Available")

derivedsex <- c(
  "Male" = "Male",
  "Female" = "Female",
  "Joint" = "Joint",
  "Sex Not Available" = "Sex Not Available")

applicant_race_1 <- c("American Indian or Alaska Native" = "American Indian or Alaska Native",
                      "Asian" = "Asian",
                      "Asian Indian" = "Asian Indian",
                      "Chinese" = "Chinese",
                      "Filipino" = "Filipino",
                      "Japanese"= "Japanese",
                      "Korean" = "Korean",
                      "Vietnamese" = "Vietnamese",
                      "Other Asian" = "Other Asian",
                      "Black or African American" = "Black or African American",
                      "Native Hawaiian or Other Pacific Islander" = "Native Hawaiian or Other Pacific Islander",
                      "Native Hawaiian" = "Native Hawaiian",
                      "Guamanian or Chamorro" = "Guamanian or Chamorro",
                      "Samoan" = "Samoan",
                      "Other Pacific Islander" = "Other Pacific Islander",
                      "White" = "White",
                      "Information not provided by applicant in mail, internet, or telephone application" = "Information not provided by applicant in mail, internet, or telephone application",
                      "Not applicable" = "Not applicable")

applicant_sex <- c(
  "Male" = "Male",
  "Female" = "Female",
  "Information not provided by applicant in mail, internet, or telephone application" = "Information not provided by applicant in mail, internet, or telephone application",
  "Not applicable" = "Not applicable",
  "Applicant selected both male and female" = "Applicant selected both male and female")
