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
  description = "The OIDC issuer URL."

  validation {
    condition     = startswith(var.issuer_url, "https://")
    error_message = "Issuer URL must start with 'https://'."
  }
}

variable "audience" {
  type        = string
  description = "The identity provider's audience."
}

variable "repositories" {
  type = list(object(
    {
      name = string
      uuid = string
      environments = optional(list(object({
        name = string
        uuid = string
        role = optional(string, "roles/editor")
      })), [])
      role = optional(string, "roles/editor")
    }
  ))
  default     = []
  description = "A list of objects that define the name and UUID of the repository and optionally environments and roles for service accounts."
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