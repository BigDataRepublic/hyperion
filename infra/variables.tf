variable "project" {
  description = "Project ID"
  default     = "playground-bart"
}

variable "shared_secret" {
  description = "IKE pre-shared secret"
  type        = string
}
