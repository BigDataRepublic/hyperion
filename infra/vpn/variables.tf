variable "project" {
  description = "Project ID"
  default     = "playground-bart"
}

variable "client_ovpn" {
  description = "client.ovpn file contents"
  type        = string
  sensitive   = true
  default     = null
}
