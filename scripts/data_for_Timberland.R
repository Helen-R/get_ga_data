if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib(c("googlesheets", "googleAuthR", "RGoogleAnalytics", "RJSONIO", "data.table", "dplyr", "RODBC"))
source("get.gaid.R")

# # [ref] http://thinktostart.com/using-google-analytics-r/
## YingYing's link https://docs.google.com/spreadsheets/d/1kjVY8MPEA4feGonMrLQ3jjLc5AmzLDvCJVER1Nba6_w/edit#gid=286209753


# 1 token & authentification
token <- gar_auth_service(json_file="cid/cid_s_ga0k.json")
# fget google sheet

gs <- gs_title("Timberland_Custom_Report")


dt1 <- sqlQuery(dbhandle(db = "DsWorkSpace"), 
                sprintf("SELECT * FROM [DsWorkSpace].[dbo].[VFCustomReportStore] 
                        WHERE YearMonth = %s OR YearMonth = %s", 201707, 201607)) %>% data.table()
v <- as.character(dt1$LocationName)
Encoding(v) <- 'utf8'
gs_edit_cells(gs, ws = gs_ws_ls(gs)[5], anchor = "A3", input = v)
