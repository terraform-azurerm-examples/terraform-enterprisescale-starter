variable "environment" {
  type = string
  validation {
    condition = contains([
      "prod",
      "canary"
    ], var.environment)
    error_message = "Environment must be prod or canary."
  }
}
