if (!"slackme" %in% ls()) source("../auxiliary/slackme.R")
# install.packages("googleComputeEngineR")

Sys.setenv("GCE_AUTH_FILE" = "C:/cid_RSpark.json")
Sys.setenv("GCE_DEFAULT_PROJECT_ID" = "rspark-158202")
Sys.setenv("GCE_DEFAULT_ZONE" = "asia-northeast1-a")
Sys.setenv("GCE_SSH_USER" = "helen")

library(googleComputeEngineR)
# library(future)
# gce_auth()
gce_get_project()
gce_list_instances()

## create vm instance
## see gce_list_machinetype() for options of predefined_type
# st <- Sys.time()
# vm <- gce_vm(template = "rstudio",
#              name = "rservice",
#              username = "helen", password = "helen",
#              predefined_type = "n1-standard-1")
# slackme("vm open", st)
# vm

gce_ssh_browser("rservice")
gce_list_instances()

# or connect / start the vm
vm <- gce_vm("helen")
## add SSH info to the VM object
vm <- gce_ssh_addkeys(username = "helen",
                      instance = vm,
                      key.pub = "~/.ssh/helen.pub",
                      key.private = "~/.ssh/helen", overwrite = T)

# # or
# ssh-keygen -t rsa -f ~/.ssh/helen -C helen

gce_ssh(vm, "echo foo", username="helen")
