library(tidyverse)

purchaser_type<- c('Not applicable'= 0,
                   'Fannie Mae'= 1,
                   'Ginnie Mae'= 2,
                   'Freddie Mac'= 3,
                   'Farmer Mac'= 4,
                   'Private securitizer'= 5,
                   'Commercial bank, savings bank, or savings association' =6,
                   'Credit union, mortgage company, or finance company'= 71,
                   'Life insurance company'= 72,
                   'Affiliate institution'= 8,
                   'Other type of purchaser'= 9)

action_taken <- c('Loan originated'= 1,
                  'Application approved but not accepted'= 2,
                  'Application denied'= 3,
                  'Application withdrawn by applicant'= 4,
                  'File closed for incompleteness'= 5,
                  'Purchased loan'= 6,
                  'Preapproval request denied'= 7,
                  'Preapproval request approved but not accepted' = 8)

applicant_credit_score_type <- c('Equifax Beacon 5.0'=1,
                                 'Experian Fair Isaac'=2,
                                 'FICO Risk Score Classic 04'=3,
                                 'FICO Risk Score Classic 98'=4,
                                 'VantageScore 2.0'=5,
                                 'VantageScore 3.0'=6,
                                 'More than one credit scoring model'=7,
                                 'Other credit scoring model'=8,
                                 'Not applicable'=9,
                                 'Exempt'=1111)

denial_reason-1 <- c('Debt-to-income ratio'= 1,
                     'Employment history'=2,
                     'Credit history'=3,
                     'Collateral'=4,
                     'Insufficient cash at downpayment or closing'= 5,
                     'Unverifiable information'= 6,
                     'Credit application incomplete'= 7,
                     'Mortgage insurance denied'=8, 
                     'Other'=9,
                     'Not applicable'= 10)

lei_df<-data_all_years %>% 
  select(lei) %>%
  unique() 
  
lei_name <- read_csv("data_science/hmda_shiny-mr_goodbar/20211218-0000-gleif-goldencopy-lei2-golden-copy.csv") 
  
lei_name<-lei_name %>% 
  select(LEI, Entity.LegalName)

filtered_lei<-merge(lei_df, lei_name, by.x= 'lei', by.y='LEI', all.x= TRUE)
data_all_years<- merge(data_all_years, filtered_lei, by.x= 'lei', by.y='lei', all.x= TRUE)
