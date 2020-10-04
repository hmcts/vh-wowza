locals {
  common_tags = {
    "managedBy"          = "Reform Video Hearings"
    "solutionOwner"      = ""
    "activityName"       = "VH"
    "dataClassification" = "Internal"
    "automation"         = "terraform"
    "costCentre"         = "10245117" // until we get a better one, this is the generic cft contingency one
    "environment"        = terraform.workspace
    "criticality"        = "Medium"
  }
}
