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
