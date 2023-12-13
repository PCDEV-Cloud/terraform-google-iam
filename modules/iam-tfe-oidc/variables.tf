variable "project" {
  type        = string
  description = "Google Project's ID where provider to be created."
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

  validation {
    condition     = alltrue(flatten([for i in var.access_configuration : [for j in i.workspaces : length(j) <= 28]]))
    error_message = "Workspace name cannot be longer than 28 characters."
  }
}
