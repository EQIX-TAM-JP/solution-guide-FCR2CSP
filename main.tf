terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    google = {
      source = "hashicorp/google"
    }
    equinix = {
      source = "equinix/equinix"
    }
  }
}

provider "aws" {
  region = var.zside_seller_region_aws
}
provider "google" {
  region  = var.google_region
  project = var.google_project_id
  zone    = var.google_zone
}

data "aws_dx_connection" "aws_connection" {
  name = var.connection_name_aws
  depends_on = [
    module.cloud_router_aws_connection
  ]
}

# FCR provision
module "fcr" {
  source         = "./modules/fcrs/"
  project_id_fcr = var.project_id_fcr
  fcr_name_a     = var.fcr_name_a
  fcr_name_b     = var.fcr_name_b
  emails         = var.notifications_emails
  metro_code_a   = var.metro_code_a
  metro_code_b   = var.metro_code_b
  bgp_auth_key = var.aws_vif_bgp_auth_key
  account_number_fcr = var.account_number_fcr
}

# AWS connection
resource "equinix_fabric_routing_protocol" "direct_aws" {
  connection_uuid = module.cloud_router_aws_connection.primary_connection_id
  type            = "DIRECT"
  name            = "direct_rp"
  direct_ipv4 {
    equinix_iface_ip = "${cidrhost(var.aws_vif_amazon_address, 2)}${substr(var.aws_vif_amazon_address, length(var.aws_vif_amazon_address) - 3, 3)}"
  }
  depends_on = [aws_dx_connection_confirmation.confirmation]
}
resource "equinix_fabric_routing_protocol" "bgp_aws" {
  connection_uuid = module.cloud_router_aws_connection.primary_connection_id
  type            = "BGP"
  name            = "bgp_lab"
  bgp_ipv4 {
    customer_peer_ip = cidrhost(var.aws_vif_amazon_address, 1)
    enabled          = true
  }
  customer_asn = var.aws_gateway_asn
  bgp_auth_key = var.aws_vif_bgp_auth_key
  depends_on = [
    aws_dx_connection_confirmation.confirmation,
    equinix_fabric_routing_protocol.direct_aws
  ]
}

resource "aws_dx_connection_confirmation" "confirmation" {
  connection_id = data.aws_dx_connection.aws_connection.id
}

module "cloud_router_aws_connection" {
  source = "equinix/fabric/equinix//modules/cloud-router-connection"

  connection_name      = var.connection_name_aws
  connection_type      = var.connection_type
  notifications_type   = var.notifications_type
  notifications_emails = var.notifications_emails
  #   additional_info       = var.additional_info
  bandwidth             = var.bandwidth_aws
  purchase_order_number = var.purchase_order_number

  #Aside
  aside_fcr_uuid = module.fcr.uuid_a

  #Zside
  zside_ap_type               = var.zside_ap_type
  zside_ap_authentication_key = var.zside_ap_authentication_key_aws
  zside_ap_profile_type       = var.zside_ap_profile_type
  zside_location              = var.zside_location_aws
  zside_seller_region         = var.zside_seller_region_aws
  zside_fabric_sp_name        = var.zside_fabric_sp_name_aws
}

resource "aws_dx_gateway" "aws_gateway" {
  depends_on = [
    module.cloud_router_aws_connection
  ]
  name            = var.aws_gateway_name
  amazon_side_asn = var.aws_gateway_asn
}

resource "aws_dx_private_virtual_interface" "aws_virtual_interface" {
  depends_on = [
    module.cloud_router_aws_connection,
    aws_dx_connection_confirmation.confirmation,
    aws_dx_gateway.aws_gateway
  ]
  connection_id    = data.aws_dx_connection.aws_connection.id
  name             = var.aws_vif_name
  vlan             = data.aws_dx_connection.aws_connection.vlan_id
  address_family   = var.aws_vif_address_family
  bgp_asn          = var.aws_vif_bgp_asn
  amazon_address   = var.aws_vif_amazon_address
  customer_address = "${cidrhost(var.aws_vif_amazon_address, 2)}${substr(var.aws_vif_amazon_address, length(var.aws_vif_amazon_address) - 3, 3)}"
  bgp_auth_key     = var.aws_vif_bgp_auth_key
  dx_gateway_id    = aws_dx_gateway.aws_gateway.id
}

#GCP connection
resource "google_compute_network" "cloud-router-google" {
  project                 = var.google_project_id
  name                    = var.google_network_name
  mtu                     = var.google_network_mtu
  auto_create_subnetworks = var.google_network_auto_create_subnetwork
}
resource "google_compute_router" "cloud-router-google" {
  name    = var.google_router_name
  network = google_compute_network.cloud-router-google.name
  bgp {
    asn = var.google_router_bgp_asn
  }
}

resource "equinix_fabric_routing_protocol" "direct_gcp" {
  connection_uuid = module.cloud_router_google_connection.primary_connection_id
  type            = "DIRECT"
  name            = "direct_rp"
  direct_ipv4 {
    equinix_iface_ip = google_compute_interconnect_attachment.cloud-router-google.customer_router_ip_address
  }
}
resource "equinix_fabric_routing_protocol" "bgp_gcp" {
  connection_uuid = module.cloud_router_google_connection.primary_connection_id
  type            = "BGP"
  name            = "bgp_lab"
  bgp_ipv4 {
    customer_peer_ip = google_compute_interconnect_attachment.cloud-router-google.cloud_router_ip_address
    enabled          = true
  }
  customer_asn = var.google_router_bgp_asn
  # bgp_auth_key = var.bgp_auth_key
  depends_on = [
    equinix_fabric_routing_protocol.direct_gcp
  ]
}

resource "google_compute_interconnect_attachment" "cloud-router-google" {
  name                     = var.google_interconnect_name
  type                     = var.google_interconnect_type
  router                   = google_compute_router.cloud-router-google.id
  region                   = var.google_region
  edge_availability_domain = var.google_interconnect_edge_availability_domain
}

module "cloud_router_google_connection" {
  source = "equinix/fabric/equinix//modules/cloud-router-connection"

  connection_name       = var.connection_name_gcp
  connection_type       = var.connection_type
  notifications_type    = var.notifications_type
  notifications_emails  = var.notifications_emails
  bandwidth             = var.bandwidth_gcp
  purchase_order_number = var.purchase_order_number

  #Aside
  aside_fcr_uuid = module.fcr.uuid_b

  #Zside
  zside_ap_type               = var.zside_ap_type
  zside_ap_authentication_key = google_compute_interconnect_attachment.cloud-router-google.pairing_key
  zside_ap_profile_type       = var.zside_ap_profile_type
  zside_location              = var.zside_location_gcp
  zside_seller_region         = var.google_region
  zside_fabric_sp_name        = var.zside_fabric_sp_name_gcp
}