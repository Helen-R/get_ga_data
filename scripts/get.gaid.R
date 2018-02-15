source("../auxiliary/dbhandle.R")

# renew gaid table

gaid <- data.table(sqlQuery(dbhandle(), "SELECT * FROM DimShopIdGaMapping"))
save(gaid, file = "cid/gaid.RData")
write.csv(gaid, "cid/gaid.csv", row.names = F)
