output "cloud_router_ip_gcp" {
  value = google_compute_interconnect_attachment.cloud-router-google.cloud_router_ip_address
}
output "customer_router_ip_gcp" {
  value = google_compute_interconnect_attachment.cloud-router-google.customer_router_ip_address
}
output "aws_connection_id" {
  value = module.cloud_router_aws_connection.primary_connection_id
}
# output "gcp_connection_id" {
#   value = module.cloud_router_google_connection.primary_connection_id
# }
