if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib(c("googlesheets", "googleAuthR", "RGoogleAnalytics", "RJSONIO", "data.table", "dplyr", "RODBC"))
# source("get.gaid.R")
# source("initiate.R")

# # [ref] http://thinktostart.com/using-google-analytics-r/
## YingYing's link https://docs.google.com/spreadsheets/d/1kjVY8MPEA4feGonMrLQ3jjLc5AmzLDvCJVER1Nba6_w/edit#gid=286209753


# 1 token & authentification
token <- gar_auth_service(json_file="../confidentials/get_ga_data/cid_s_ga0k.json")
# fget google sheet
# gs <- gs_title("GA tracking note_draft")
# ws <- gs_ws_ls(gs)[grep("Bounce rate", gs_ws_ls(gs))]
# tab <- gs_read(gs, ws=ws)
# target.ids <- colnames(tab)[-1]

# 2 view.id lis
# gaid <- data.table(sqlQuery(dbhandle(), "SELECT * FROM DimShopIdGaMapping"))
load("../confidentials/get_ga_data/gaid.RData")
# gaid <- gaid[Status=="Open"&Type=="OfficialShop"] %>% 
#   unique(by = "ProfileId")
condi <- quote(ShopId %in% target.ids)
ga.tab <- gaid[eval(condi), .(ShopId, ProfileId, Owner, SourceDef)][SourceDef!="APP"]
view.ids <- ga.tab[, .(ProfileId)] %>% 
  unlist()
shop.ids <- ga.tab[, .(ShopId)] %>% 
  unlist()
names(view.ids) <- paste0("ShopId.", shop.ids)
# ga?k
nks <- ga.tab[,.(Owner)] %>%
  unlist() %>% 
  gsub(pattern = "pd_", replacement = "") %>% 
  gsub(pattern = "@nine-yi.com", replacement = "")
names(nks) <- paste0("ShopId.", shop.ids)

get.ga.data <- function (shop.id, st.dt, ed.dt) {
  st.dt <- as.character(st.dt)
  ed.dt <- as.character(ed.dt)
  idx <- paste0("ShopId.", shop.id)
  
  nk <- nks[idx]
  cat(sprintf("%s_%s\n", shop.id, nk))
  
  token <- gar_auth_service(json_file=sprintf("../confidentials/get_ga_data/cid_s_%s.json", nk))
  ValidateToken(token)
  
  view.id <- view.ids[idx]
  # Build a list of all the Query Parameters
  query.list <- Init(start.date = st.dt,
                     end.date = ed.dt,
                     dimension = "ga:source,ga:medium",
                     metrics = "ga:bounceRate,ga:sessions,ga:users",
                     # filters = "ga:pagePath ==/v2/official",
                     # max.results = 10000,
                     # sort = "-ga:date",
                     table.id = sprintf("ga:%s", view.id))
  
  # Create the Query Builder object so that the query parameters are validated
  ga.query <- QueryBuilder(query.list)
  GetReportData(ga.query, token, split_daywise = F)
}


## daily (or batch) call
st.dt <- Sys.Date()-2
ed.dt <- Sys.Date()-1
# get.ga.data(shop.id = shop.ids[1], st.dt, ed.dt)
tmp <- lapply(shop.ids, get.ga.data, st.dt, ed.dt)