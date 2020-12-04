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
  criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "sandbox|Environment"
      }
    }
}

resource "nsxt_policy_group" "TestPCI" {
  display_name = "Test PCI"
  description  = "Test PCI Group provisioned by Terraform"
  criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "test|Environment"
      }
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "pci|compliance"
      }
    }
}
resource "nsxt_policy_group" "TestNonPCI" {
  display_name = "Test Non-PCI"
  description  = "Test Non-PCI Group provisioned by Terraform"
    criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "test|Environment"
      }
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "nonpci|compliance"
      }
    }
}
resource "nsxt_policy_group" "ProdPCI" {
  display_name = "Prod PCI"
  description  = "Prod PCI Group provisioned by Terraform"
  criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "Prod|Environment"
      }
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "pci|compliance"
      }
    }
}
resource "nsxt_policy_group" "ProdNonPCI" {
  display_name = "Prod Non-PCI"
  description  = "Prod Non-PCI NSGroup provisioned by Terraform"
    criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "Prod|Environment"
      }
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "nonpci|compliance"
      }
    }
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

resource "nsxt_policy_group" "SharedServices" {
  display_name = "Shared Services"
  description  = "Shared Services Group provisioned by Terraform"
  criteria {
    ipaddress_expression {
      ip_addresses = ["10.100.0.142","10.100.0.5"]
    }
  }
}

resource "nsxt_policy_group" "ProtectedAssets" {
  display_name = "Protected Assets"
  description  = "Protected Assets Group provisioned by Terraform"
  criteria {
    ipaddress_expression {
      ip_addresses = ["10.100.65.0/24"]
    }
  }
}

resource "nsxt_policy_security_policy" "PrivateCloudGuardrail" {
  description  = "Private Cloud Guardrails Section provisioned by Terraform"
  display_name = "Private Cloud Guardrails"
  category = "Environment"
  rule {
    display_name = "Allow Shared Services"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.PrivateCloud.path]
    destination_groups = [nsxt_policy_group.SharedServices.path]
    scope = [nsxt_policy_group.PrivateCloud.path, nsxt_policy_group.SharedServices.path]
  }
   rule {
    display_name = "Reject Protected Assets"
    description  = ""
    action       = "REJECT"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.PrivateCloud.path]
    destination_groups = [nsxt_policy_group.ProtectedAssets.path]
    scope = [nsxt_policy_group.PrivateCloud.path, nsxt_policy_group.ProtectedAssets.path]
  }
  rule {
    display_name = "Open inside Sandbox"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.Sandbox.path]
    destination_groups = [nsxt_policy_group.Sandbox.path]
    scope = [nsxt_policy_group.Sandbox.path]
  }
    rule {
    display_name = "Private Cloud to Sandbox"
    description  = ""
    action       = "REJECT"
    ip_version  = "IPV4"
    source_groups = [nsxt_policy_group.PrivateCloud.path]
    destination_groups = [nsxt_policy_group.Sandbox.path]
    scope = [nsxt_policy_group.PrivateCloud.path, nsxt_policy_group.Sandbox.path]
  }
  rule {
    display_name = "Any to Sandbox"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    destination_groups = [nsxt_policy_group.Sandbox.path]
    scope = [nsxt_policy_group.Sandbox.path]
  }
}

resource "nsxt_policy_security_policy" "PrivateCloudGuardrailDenyList" {
  description  = "Private Cloud Default Section provisioned by Terraform"
  display_name = "Private Cloud Default Deny"
  category = "Application"
  sequence_number = 59999
  rule {
    display_name = "Default Deny (Reject)"
    description  = ""
    action       = "REJECT"
    ip_version  = "IPV4"
    destination_groups =  [nsxt_policy_group.PrivateCloud.path]
  }
}