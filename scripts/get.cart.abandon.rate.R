if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
if (!"mylib" %in% ls()) source("../auxiliary/mylib.R")
mylib(c("googlesheets", "googleAuthR", "googleAnalyticsR", "RJSONIO", 
        "data.table", "dplyr", "plyr", "RODBC"))
source("get.gaid.R")

# 1 token & authentification
token <- gar_auth_service(json_file="cid/cid_s_ga0k.json")

## daily (or batch) call
st.dt <- floor_date(today(), unit = "month")
ed.dt <- today() - 1

load("cid/gaid.RData")
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
  x <- google_analytics_4(view.id, 
                     date_range = c(st.dt, ed.dt),
                     metrics = "sessions",
                     dimensions = "shoppingStage")
  setnames(x, "sessions", names(view.id))
}

options(stringsAsFactors = F)

tmp <- lapply(shop.ids, get.ga.data, st.dt, ed.dt) %>% 
  join_all(., by = "shoppingStage")
tmp1 <- tmp[, -1] %>% as.matrix() %>% t() %>% as.data.table()
setnames(tmp1, colnames(tmp1), tmp[, 1])
tmp1[, abd.rate := CART_ABANDONMENT / ADD_TO_CART]
# colnames(tmp)[which.min(tmp1$abd.rate)]
# colnames(tmp)[-1][which.min(tmp1$abd.rate)]
df <- data.frame(shop.id=as.integer(gsub("ShopId.", "", colnames(tmp)[-1])), 
                 abd.rate=paste0(round(tmp1$abd.rate*100, 1), "%"),
                 abd.rate.value=tmp1$abd.rate)
shop.ls <- sqlQuery(dbhandle(), "select ShopId,ShopName,ShopCategoryName from DimShop")
shop.ls <- shop.ls[shop.ls$ShopId%in%shop.ids,]
df <- left_join(df, shop.ls, by = c("shop.id"="ShopId"))
setorder(df, abd.rate.value)





st.dt <- as.Date("2017-09-01")
ed.dt <- as.Date("2017-10-01")

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
  x <- google_analytics_4(view.id, 
                          date_range = c(st.dt, ed.dt),
                          metrics = "users",
                          dimensions = "userAgeBracket")
  setnames(x, "sessions", names(view.id))
}