# Configure the VMware NSX-T Provider
provider "nsxt" {
    host = var.nsxIP
    username = var.nsxUser
    password = var.nsxPassword
    allow_unverified_ssl = true
}

resource "nsxt_policy_group" "Sandbox" {
  display_name = "Sandbox"
  description  = "Sandbox Group provisioned by Terraform"
}

resource "nsxt_policy_group" "TestPCI" {
  display_name = "Test PCI"
  description  = "Test PCI Group provisioned by Terraform"

}
resource "nsxt_policy_group" "TestNonPCI" {
  display_name = "Test Non-PCI"
  description  = "Test Non-PCI Group provisioned by Terraform"

}
resource "nsxt_policy_group" "ProdPCI" {
  display_name = "Prod PCI"
  description  = "Prod PCI Group provisioned by Terraform"

}
resource "nsxt_policy_group" "ProdNonPCI" {
  display_name = "Prod Non-PCI"
  description  = "Prod Non-PCI NSGroup provisioned by Terraform"
}

resource "nsxt_policy_group" "PrivateCloud" {
  display_name = "Private Cloud 2.0"
  description  = "Private Cloud Group provisioned by Terraform"
  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.Sandbox.path,nsxt_policy_group.ProdPCI.path,nsxt_policy_group.ProdNonPCI.path, nsxt_policy_group.TestPCI.path, nsxt_policy_group.TestNonPCI.path ]
    }
  }
}
