################################################################################
# Identity Pools
################################################################################

locals {
  list_of_identity_pools = flatten([for i in var.access_configuration : {
    id           = lower(replace("tfe-${i.organization}-${i.project}", "/[\\s_]/", "-"))
    description  = "TFE Project='${i.project}', Organization='${i.organization}'"
    organization = i.organization
    project      = i.project
  }])

  identity_pools = { for i in local.list_of_identity_pools : "${i.organization}/${i.project}" => i }
}

resource "google_iam_workload_identity_pool" "this" {
  for_each = local.identity_pools

  workload_identity_pool_id = each.value["id"]          # Can have lowercase letters, digits or hyphens (-). Must be at least 4 characters long. Must be at most 32 characters long.
  display_name              = each.value["id"]          # Must be at most 32 characters long.
  description               = each.value["description"] # Must be at most 256 characters long. (31+36+40)
  disabled                  = false
  project                   = var.project
}

################################################################################
# Providers
################################################################################

locals {
  list_of_providers = flatten([for i in var.access_configuration : [for j in i.workspaces : {
    id           = lower(replace("tfe-${j}", "/[\\s_]/", "-"))
    description  = "TFE Workspace='${i.workspace}', Project='${i.project}', Organization='${i.organization}'"
    organization = i.organization
    project      = i.project
    workspace    = j
  }]])

  providers = { for i in local.list_of_providers : "${i.organization}/${i.project}/${i.workspace}" => i }
}

resource "google_iam_workload_identity_pool_provider" "this" {
  for_each = local.providers

  workload_identity_pool_id          = google_iam_workload_identity_pool.this["${each.value["organization"]}/${each.value["project"]}"].workload_identity_pool_id
  workload_identity_pool_provider_id = each.value["id"]          # Can have lowercase letters, digits or hyphens (-). Must be at least 4 characters long. Must be at most 32 characters long.
  display_name                       = each.value["id"]          # Must be at most 32 characters long.
  description                        = each.value["description"] # Must be at most 256 characters long. (45+90+36+40)
  disabled                           = false
  project                            = var.project

  oidc {
    issuer_uri = var.issuer_url
  }

  attribute_mapping = {
    "google.subject"                  = "assertion.sub"
    "attribute.tfe_organization_name" = "assertion.terraform_organization_name"
    "attribute.tfe_project_name"      = "assertion.terraform_project_name"
    "attribute.tfe_workspace_name"    = "assertion.terraform_workspace_name"
  }

  attribute_condition = "'organization:${each.value["organization"]}:project:${each.value["project"]}:workspace:${each.value["workspace"]}' in assertion.sub"

  depends_on = [
    google_iam_workload_identity_pool.this
  ]
}

################################################################################
# Service Accounts
################################################################################

locals {
  list_of_apply_service_accounts = flatten([for i in var.access_configuration : {
    account_id   = lower(replace("tfe-apply-${i.organization}-${i.project}", "/[\\s_]/", "-"))
    description  = "TFE Project='${i.project}', Organization='${i.organization}'"
    organization = i.organization
    project      = i.project
  }])

  list_of_plan_service_accounts = flatten([for i in var.access_configuration : {
    account_id   = lower(replace("tfe-plan-${i.organization}-${i.project}", "/[\\s_]/", "-"))
    description  = "TFE Project='${i.project}', Organization='${i.organization}'"
    organization = i.organization
    project      = i.project
  } if i.split_run_phase])

  apply_service_accounts = { for i in local.list_of_apply_service_accounts : "${i.organization}/${i.project}" => i }
  plan_service_accounts  = { for i in local.list_of_plan_service_accounts : "${i.organization}/${i.project}" => i }
}

resource "google_service_account" "apply" {
  for_each = local.apply_service_accounts

  account_id   = each.value["account_id"]  # Can have lowercase letters, digits or hyphens (-). Must be at least 6 characters long. Must be at most 30 characters long.
  display_name = each.value["account_id"]  # Must be at most 30 characters long.
  description  = each.value["description"] # Must be at most 256 characters long. (31+36+40)
  disabled     = false
  project      = var.project
}

resource "google_service_account_iam_binding" "apply" {
  for_each = local.apply_service_accounts

  service_account_id = google_service_account.apply[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["principal://iam.googleapis.com/${google_iam_workload_identity_pool.this["${each.value["organization"]}/${each.value["project"]}"].name}/subject/sub"]
}

resource "google_project_iam_member" "apply" {
  for_each = local.apply_service_accounts

  project = var.project
  role    = "roles/editor" # TODO: to variable
  member  = google_service_account.apply[each.key].member

  # TODO: dynamic condition
  # condition {
  #   title       = ""
  #   description = ""
  #   expression  = ""
  # }
}

resource "google_service_account" "plan" {
  for_each = local.plan_service_accounts

  account_id   = each.value["account_id"]  # Can have lowercase letters, digits or hyphens (-). Must be at least 6 characters long. Must be at most 30 characters long. 
  display_name = each.value["account_id"]  # Must be at most 30 characters long.
  description  = each.value["description"] # Must be at most 256 characters long. (31+36+40)
  disabled     = false
  project      = var.project
}

resource "google_service_account_iam_binding" "plan" {
  for_each = local.plan_service_accounts

  service_account_id = google_service_account.plan[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["principal://iam.googleapis.com/${google_iam_workload_identity_pool.this["${each.value["organization"]}/${each.value["project"]}"].name}/subject/sub"]
}

resource "google_project_iam_member" "plan" {
  for_each = local.plan_service_accounts

  project = var.project
  role    = "roles/viewer" # TODO: to variable
  member  = google_service_account.plan[each.key].member

  # TODO: dynamic condition
  # condition {
  #   title       = ""
  #   description = ""
  #   expression  = ""
  # }
}