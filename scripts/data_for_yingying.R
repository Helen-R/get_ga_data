if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib(c("googlesheets", "googleAuthR", "RGoogleAnalytics", "RJSONIO", "data.table", "dplyr", "RODBC"))
source("get.gaid.R")

# # [ref] http://thinktostart.com/using-google-analytics-r/
## YingYing's link https://docs.google.com/spreadsheets/d/1kjVY8MPEA4feGonMrLQ3jjLc5AmzLDvCJVER1Nba6_w/edit#gid=286209753


# 1 token & authentification
token <- gar_auth_service(json_file="cid/cid_s_ga0k.json")
# fget google sheet
gs <- gs_title("GA tracking note_draft")
ws <- gs_ws_ls(gs)[grep("Bounce rate", gs_ws_ls(gs))]
tab <- gs_read(gs, ws=ws)
target.ids <- colnames(tab)[-1]
# dates <- tab[-1, 1]

# 2 view.id lis
# gaid <- data.table(sqlQuery(dbhandle(), "SELECT * FROM DimShopIdGaMapping"))
load("cid/gaid.RData")
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
# nks[7:9] <- "ga0k"

get.ga.data <- function (shop.id, st.dt, ed.dt) {
  st.dt <- as.character(st.dt)
  ed.dt <- as.character(ed.dt)
  idx <- paste0("ShopId.", shop.id)

  nk <- nks[idx]
  cat(sprintf("%s_%s\n", shop.id, nk))
  
  token <- gar_auth_service(json_file=sprintf("cid/cid_s_%s.json", nk))
  ValidateToken(token)
  
  view.id <- view.ids[idx]
  # Build a list of all the Query Parameters
  query.list <- Init(start.date = st.dt,
                     end.date = ed.dt,
                     dimension = "ga:date",
                     metrics = "ga:bounceRate,ga:avgSessionDuration",
                     filters = "ga:pagePath ==/v2/official",
                     # max.results = 10000,
                     # sort = "-ga:date",
                     table.id = sprintf("ga:%s", view.id))
  
  # Create the Query Builder object so that the query parameters are validated
  ga.query <- QueryBuilder(query.list)
  GetReportData(ga.query, token, split_daywise = F)
}


## daily (or batch) call
st.dt <- as.Date(tab$Shop[which(is.na(tab$`14`))[1]])
ed.dt <- Sys.Date()-1
# get.ga.data(shop.id = shop.ids[1], st.dt, ed.dt)
tmp <- lapply(shop.ids, get.ga.data, st.dt, ed.dt)
input.data <- sapply(tmp, "[[", "bounceRate")
is.one.row <- ifelse(is.null(nrow(input.data)), T, F)
if(is.one.row) {
  names(input.data) <- paste0("ShopId.", shop.ids)
  input.data <- input.data[paste0("ShopId.", target.ids)]
} else {
  colnames(input.data) <- paste0("ShopId.", shop.ids)
  input.data <- input.data[, paste0("ShopId.", target.ids)]
}
cellrow <- which(tab$Shop==format(st.dt, "%Y/%m/%d")) + 1
gs_edit_cells(gs, input = input.data / 100, ws = ws, col_names = F,
              anchor = sprintf("B%s", cellrow), byrow = is.one.row)
