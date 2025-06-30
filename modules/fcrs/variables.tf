
variable "emails" {
  description = "Array of contact emails"
  type        = list(string)
}

# variable "customer_peer_ip_aws" {
#   description = "The IPv4 CIDR address to use to send traffic to Amazon. Required for IPv4 BGP peers"
#   type        = string
#   default     = ""
# }
# variable "customer_peer_ip_gcp" {
#   description = "The IPv4 CIDR address to use to send traffic to Amazon. Required for IPv4 BGP peers"
#   type        = string
#   default     = ""
# }
variable "bgp_auth_key" {
  description = "The authentication key for BGP configuration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "fcr_name_a" {}
variable "fcr_name_b" {}
variable "metro_code_a" {}
variable "metro_code_b" {}

variable "project_id_fcr" {}
variable "account_number_fcr" {}