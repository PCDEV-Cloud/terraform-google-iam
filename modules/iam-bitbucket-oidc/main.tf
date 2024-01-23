################################################################################
# Identity Pools
################################################################################

locals {
  workspace_uuid = trimsuffix(trimprefix("https://api.bitbucket.org/2.0/workspaces/thesoftwarehouse/pipelines-config/identity/oidc", "https://api.bitbucket.org/2.0/workspaces/"), "/pipelines-config/identity/oidc")

  list_of_identity_pools = [
    {
      id = lower(replace("bb-${var.randomize_identity_pool_id ? substr(local.workspace_uuid, 0, 23) : substr(local.workspace_uuid, 0, 29)}", "/[\\s_]/", "-"))
    }
  ]

  identity_pools = { for i in local.list_of_identity_pools : local.workspace_uuid => i }
}

resource "random_string" "identity_pool_id" {
  for_each = var.randomize_identity_pool_id ? local.identity_pools : tomap({})

  length  = 5
  numeric = true
  lower   = false
  upper   = false
  special = false
}

resource "google_iam_workload_identity_pool" "this" {
  for_each = local.identity_pools

  workload_identity_pool_id = var.randomize_identity_pool_id ? join("-", [each.value["id"], random_string.identity_pool_id[each.key].id]) : each.value["id"] # Can have lowercase letters, digits or hyphens (-). Must be at least 4 characters long. Must be at most 32 characters long.
  display_name              = var.randomize_identity_pool_id ? join("-", [each.value["id"], random_string.identity_pool_id[each.key].id]) : each.value["id"] # Must be at most 32 characters long.
  description               = "Bitbucket"                                                                                                                    # Must be at most 256 characters long. (31+36+40)
  disabled                  = false
  project                   = var.project
}

################################################################################
# Providers
################################################################################

locals {
  list_of_providers = flatten([for i in var.repositories : {
    id   = lower(replace("bb-${var.randomize_provider_id ? substr(i.name, 0, 23) : substr(i.name, 0, 29)}", "/[\\s_]/", "-"))
    name = i.name
    uuid = i.uuid
  }])

  providers = { for i in local.list_of_providers : i.name => i }
}

resource "random_string" "provider_id" {
  for_each = var.randomize_provider_id ? local.providers : tomap({})

  length  = 5
  numeric = true
  lower   = false
  upper   = false
  special = false
}

resource "google_iam_workload_identity_pool_provider" "this" {
  for_each = local.providers

  workload_identity_pool_id          = google_iam_workload_identity_pool.this[local.workspace_uuid].workload_identity_pool_id
  workload_identity_pool_provider_id = var.randomize_provider_id ? join("-", [each.value["id"], random_string.provider_id[each.key].id]) : each.value["id"] # Can have lowercase letters, digits or hyphens (-). Must be at least 4 characters long. Must be at most 32 characters long.
  display_name                       = var.randomize_provider_id ? join("-", [each.value["id"], random_string.provider_id[each.key].id]) : each.value["id"] # Must be at most 32 characters long.
  description                        = "Bitbucket"                                                                                                          # Must be at most 256 characters long. (45+90+36+40)
  disabled                           = false
  project                            = var.project

  oidc {
    issuer_uri        = var.issuer_url
    allowed_audiences = [var.audience]
  }

  attribute_mapping = {
    "google.subject"           = "assertion.sub"
    "attribute.workspace_uuid" = "assertion.workspaceUuid"
  }

  attribute_condition = "attribute.workspace_uuid == '${local.workspace_uuid}' && google.subject == '${each.value["uuid"]}'"
}

################################################################################
# Service Accounts
################################################################################

locals {
  list_of_service_accounts = flatten([for i in var.repositories : {
    account_id      = lower(replace("bb-${var.randomize_provider_id ? substr(i.name, 0, 21) : substr(i.name, 0, 27)}", "/[\\s_]/", "-"))
    display_name    = lower(replace("bb-${i.name}", "/[\\s_]/", "-"))
    repository_name = i.name
    repository_uuid = i.uuid
    role            = i.role
  } if length(tolist(i.environments)) == 0])

  service_accounts = { for i in local.list_of_service_accounts : i.repository => i }
}

resource "random_string" "service_account_id" {
  for_each = var.randomize_service_account_id ? local.service_accounts : tomap({})

  length  = 5
  numeric = true
  lower   = false
  upper   = false
  special = false
}

resource "google_service_account" "this" {
  for_each = local.service_accounts

  account_id   = var.randomize_service_account_id ? join("-", [each.value["account_id"], random_string.service_account_id[each.key].id]) : each.value["account_id"] # Can have lowercase letters, digits or hyphens (-). Must be at least 6 characters long. Must be at most 30 characters long.
  display_name = each.value["display_name"]                                                                                                                         # Must be at most 30 characters long.
  description  = "Service Account for Bitbucket"                                                                                                                    # Must be at most 256 characters long. (31+36+40)
  disabled     = false
  project      = var.project
}

resource "google_service_account_iam_binding" "this" {
  for_each = local.service_accounts

  service_account_id = google_service_account.this[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["principal://iam.googleapis.com/${google_iam_workload_identity_pool.this[local.workspace_uuid].name}/attribute.workspace_uuid/${local.workspace_uuid}"]
}

resource "google_project_iam_member" "this" {
  for_each = local.service_accounts

  project = var.project
  role    = each.value["role"]
  member  = google_service_account.this[each.key].member
}

################################################################################
# Service Accounts - Environment
################################################################################

locals {
  list_of_environment_service_accounts = flatten([for i in var.repositories : [for j in i.environments : {
    account_id       = lower(replace("bb-${var.randomize_service_account_id ? substr(join("-", [i.name, j.name]), 0, 21) : substr(join("-", [i.name, j.name]), 0, 27)}", "/[\\s_]/", "-"))
    display_name     = lower(replace("bb-${j.name}", "/[\\s_]/", "-"))
    repository_name  = i.name
    repository_uuid  = i.uuid
    environment_name = j.name
    environment_uuid = j.uuid
    role             = j.role
  }]])

  environment_service_accounts = { for i in local.list_of_environment_service_accounts : "${i.repository}/${i.environment}" => i }
}

resource "random_string" "environment_service_account_id" {
  for_each = var.randomize_service_account_id ? local.environment_service_accounts : tomap({})

  length  = 5
  numeric = true
  lower   = false
  upper   = false
  special = false
}

resource "google_service_account" "environment" {
  for_each = local.environment_service_accounts

  account_id   = var.randomize_service_account_id ? join("-", [each.value["account_id"], random_string.environment_service_account_id[each.key].id]) : each.value["account_id"] # Can have lowercase letters, digits or hyphens (-). Must be at least 6 characters long. Must be at most 30 characters long.
  display_name = each.value["display_name"]                                                                                                                                     # Must be at most 30 characters long.
  description  = "Service Account for Bitbucket"                                                                                                                                # Must be at most 256 characters long. (31+36+40)
  disabled     = false
  project      = var.project
}

resource "google_service_account_iam_binding" "environment" {
  for_each = local.environment_service_accounts

  service_account_id = google_service_account.environment[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["principal://iam.googleapis.com/${google_iam_workload_identity_pool.this[local.workspace_uuid].name}/attribute.workspace_uuid/${local.workspace_uuid}"]
}

resource "google_project_iam_member" "environment" {
  for_each = local.environment_service_accounts

  project = var.project
  role    = each.value["role"]
  member  = google_service_account.environment[each.key].member
}