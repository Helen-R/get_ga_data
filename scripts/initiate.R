library(googleAuthR)
options(googleAuthR.client_id = "r-service@hazel-phoenix-133609.iam.gserviceaccount.com")
options(googleAuthR.client_secret = "104007673810363990822")
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/analytics",
                                        "https://www.googleapis.com/auth/webmasters"))


# # set the scopes required
# scopes = c("https://www.googleapis.com/auth/analytics", 
#            "https://www.googleapis.com/auth/webmasters")
# 
# # set the client
# gar_set_client("cid/cid_s_ga0k.json", scopes = scopes)
gar_auth(new_user=TRUE)
