
terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
    }
  }
}
resource "equinix_fabric_cloud_router" "new_cloud_router_a"{
  name = var.fcr_name_a
  type = "XF_ROUTER"
  notifications{
    type = "ALL"
    emails = var.emails
  }
  order {
    purchase_order_number = "1-111111"
  }
  location {
    metro_code = var.metro_code_a
  }
  package {
    code = "STANDARD"
  }
  project {
      project_id = var.project_id_fcr
  }
  account {
      account_number = var.account_number_fcr
  }
}
resource "equinix_fabric_cloud_router" "new_cloud_router_b"{
  name = var.fcr_name_b
  type = "XF_ROUTER"
  notifications{
    type = "ALL"
    emails = var.emails
  }
  order {
    purchase_order_number = "1-323292"
  }
  location {
    metro_code = var.metro_code_b
  }
  package {
    code = "STANDARD"
  }
  project {
      project_id = var.project_id_fcr
  }
  account {
      account_number = var.account_number_fcr
  }
}