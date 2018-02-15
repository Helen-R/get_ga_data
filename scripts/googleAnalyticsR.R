if(!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib("googleAnalyticsR")
# or 
# devtools::install_github("MarkEdmondson1234/googleAnalyticsR")

ga_auth(new_user = T)

## get your accounts
account_list <- google_analytics_account_list()
