# output "equinix_peer_ip_aws" {
#   value = [for bgp in equinix_fabric_routing_protocol.bgp_aws.bgp_ipv4 : bgp.equinix_peer_ip]
# }
# output "equinix_peer_ip_gcp" {
#   value = [for bgp in equinix_fabric_routing_protocol.bgp_gcp.bgp_ipv4 : bgp.equinix_peer_ip]
# }
output "uuid_a" {
  value = equinix_fabric_cloud_router.new_cloud_router_a.uuid
}
output "uuid_b" {
  value = equinix_fabric_cloud_router.new_cloud_router_b.uuid
}