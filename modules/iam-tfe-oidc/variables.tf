variable "project" {
  type        = string
  description = "Google Project's ID (without `projects/` prefix) where provider to be created."

  validation {
    condition     = !startswith(var.project, "projects/")
    error_message = "The project ID must be provided without the `projects/` prefix."
  }
}

variable "issuer_url" {
  type        = string
  default     = "https://app.terraform.io"
  description = "The OIDC issuer URL."

  validation {
    condition     = startswith(var.issuer_url, "https://")
    error_message = "Issuer URL must start with 'https://'."
  }
}

variable "access_configuration" {
  type = list(object({
    organization    = string
    project         = optional(string, "Default")
    workspaces      = list(string)
    split_run_phase = optional(bool, false)
  }))
  description = "A list of objects in which access to the Google Project is defined. Each object creates a workload identity pool with providers for each workspace, service accounts and optionally grants permissions."

  validation {
    condition     = length([for i in var.access_configuration : merge(i, { split_run_phase = null })]) == length(distinct([for i in var.access_configuration : merge(i, { split_run_phase = null })]))
    error_message = "All list items must be unique. The 'split_run_phase' value is not included in the argument when checked."
  }
}

variable "randomize_identity_pool_id" {
  type        = bool
  default     = true
  description = "Whether to add a random string at the end of the Workload Identity Pool ID."
}

variable "randomize_provider_id" {
  type        = bool
  default     = true
  description = "Whether to add a random string at the end of the Identity Provider ID."
}

variable "randomize_service_account_id" {
  type        = bool
  default     = true
  description = "Whether to add a random string at the end of the Service Account ID."
}

variable "apply_phase_role" {
  type        = string
  default     = "roles/owner"
  nullable    = false
  description = "Default role for Service Account for the apply run phase. If `split_run_phase = false` this will be the default role for the Service Account for all run phases."
}

variable "plan_phase_role" {
  type        = string
  default     = "roles/viewer"
  nullable    = false
  description = "Default role for Service Account for the plan run phase if `split_run_phase = true`."
}