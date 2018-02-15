if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib(c("googlesheets", "googleAuthR", "RGoogleAnalytics", "RJSONIO", "data.table", "dplyr", "RODBC"))

# # [ref] http://thinktostart.com/using-google-analytics-r/

# 1 token & authentification
token <- gar_auth_service(json_file="cid/cid_s_ga0k.json")
# fget google sheet
gs <- gs_title("商品頁改版_觀察指標")
wsls <- gs_ws_ls(gs)[3:12]
target.ids <- as.integer(sapply(strsplit(wsls, ".", fixed = T), "[", 1))
date.range <- gs_read(gs, ws="14.糖罐子_服飾", range = cell_rows(6), col_names = FALSE)
date.range <- unlist(date.range[-length(date.range)])
date.range <- strsplit(date.range, "-", fixed = T)
date.range <- lapply(date.range, strptime, format="%m/%e")
date.range <- lapply(date.range, as.character)
  
# 2 view.id lis
# source("get.gaid.R")
load("cid/gaid.RData")
gaid <- gaid[Status=="Open"&Type=="OfficialShop"] %>% 
        unique(by = "ProfileId")
condi <- quote(ShopId %in% target.ids)
ga.tab <- gaid[eval(condi), .(ShopId, ProfileId, Owner, Type)]
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



# # Authorize the Google Analytics account
# # This need not be executed in every session once the token object is created 
# # and saved
# x <- fromJSON("cid_ga1k.json")
# token <- Auth(client.id = x$installed$client_id, client.secret = x$installed$client_secret)
# 
# # Save the token object for future sessions
# save(token, file="./token_ga1k_file")
# # In future sessions it can be loaded by running load("./token_file")

get.ga.data <- function (shop.id, st.dt, ed.dt) {
  idx <- paste0("ShopId.", shop.id)
  if (shop.id %in% c(360, 815)) {
    nk <- "ga0k"
  } else {
    nk <- nks[idx]
  }
  cat(paste(shop.id, nk, sep="_"))
  
  token <- gar_auth_service(json_file=sprintf("cid/cid_s_%s.json", nk))
  ValidateToken(token)
  
  # st.dt <- "2017-03-09"
  # # ed.dt <- (as.Date(st.dt) + 6) %>% as.character()
  # ed.dt <- "2017-03-19"
  
  view.id <- view.ids[idx]
  # Build a list of all the Query Parameters
  query.list <- Init(start.date = st.dt,
                     end.date = ed.dt,
                     metrics = "ga:bounceRate,ga:avgSessionDuration",
                     filters = "ga:pagePath =~/SalePage/",
                     # max.results = 10000,
                     # sort = "-ga:date",
                     table.id = sprintf("ga:%s", view.id))
  
  # Create the Query Builder object so that the query parameters are validated
  ga.query <- QueryBuilder(query.list)
  GetReportData(ga.query, token, split_daywise = F)
}

d <- list()
for (i in 1:length(date.range)) {
  st.dt <- date.range[[i]][1]
  cat(st.dt)
  ed.dt <- date.range[[i]][2]
  d[i] <- sapply(shop.ids, get.ga.data, st.dt, ed.dt)
}

dd <- data.frame()
for (x in d) {
  dd <- rbind(dd, x)
}
