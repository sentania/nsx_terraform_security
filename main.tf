# Configure the VMware NSX-T Provider
provider "nsxt" {
    host = var.nsxIP
    username = var.nsxUser
    password = var.nsxpassword
    allow_unverified_ssl = true
}

resource "nsxt_ip_set" "SharedServices" {
  description  = "Infrastructure provisioned by Terraform"
  display_name = "Shared Services"
  ip_addresses = ["10.100.100.30", "10.101.100.30", "10.100.0.136"]
}

resource "nsxt_ip_set" "ProtectedAssets" {
  description  = "Protected Assets provisioned by Terraform"
  display_name = "Protected Assets"
  ip_addresses = ["10.100.65.0/24"]
}
resource "nsxt_ns_group" "Sandbox" {
  display_name = "Sandbox"
  description  = "Sandbox NSGroup provisioned by Terraform"
}

resource "nsxt_ns_group" "TestPCI" {
  display_name = "Test PCI"
  description  = "Test PCI NSGroup provisioned by Terraform"

}
resource "nsxt_ns_group" "TestNonPCI" {
  display_name = "Test Non-PCI"
  description  = "Test Non-PCI NSGroup provisioned by Terraform"

}
resource "nsxt_ns_group" "ProdPCI" {
  display_name = "Prod PCI"
  description  = "Prod PCI NSGroup provisioned by Terraform"

}
resource "nsxt_ns_group" "ProdNonPCI" {
  display_name = "Prod Non-PCI"
  description  = "Prod Non-PCI NSGroup provisioned by Terraform"
}

resource "nsxt_ns_group" "PrivateCloud" {
  display_name = "Private Cloud"
  description  = "Private Cloud NSGroup provisioned by Terraform"
  member {
    target_type = "NSGroup"
    value = "${nsxt_ns_group.Sandbox.id}"
  }
    member {
    target_type = "NSGroup"
    value = "${nsxt_ns_group.TestPCI.id}"
  }
    member {
    target_type = "NSGroup"
    value = "${nsxt_ns_group.TestNonPCI.id}"
  }
    member {
    target_type = "NSGroup"
    value = "${nsxt_ns_group.ProdPCI.id}"
  }
    member {
    target_type = "NSGroup"
    value = "${nsxt_ns_group.ProdNonPCI.id}"
  }
}

resource "nsxt_firewall_section" "PrivateCloudGaurdrailWhitelist" {
  description  = "Private Cloud Whitelist Section provisioned by Terraform"
  display_name = "Private Cloud Whitelist"
  section_type = "LAYER3"
  stateful     = true
   applied_to {
    target_type = "NSGroup"
    target_id   = nsxt_ns_group.PrivateCloud.id
  }
    rule {
    display_name = "Reject Protected Assets"
    description  = ""
    action       = "REJECT"
    logged       = false
    ip_protocol  = "IPV4"
    source {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.PrivateCloud.id
    }    
    destination {
      target_type = "IPSet"
      target_id   = nsxt_ip_set.ProtectedAssets.id
    }
  }
    rule {
    display_name = "Allow Sandbox Comms"
    description  = ""
    action       = "ALLOW"
    logged       = false
    ip_protocol  = "IPV4"
    source {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.Sandbox.id
    }    
    destination {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.Sandbox.id
    }
  }
    rule {
    display_name = "Allow Shared Services"
    description  = ""
    action       = "ALLOW"
    logged       = false
    ip_protocol  = "IPV4"
    source {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.PrivateCloud.id
    }    
    destination {
      target_type = "IPSet"
      target_id   = nsxt_ip_set.SharedServices.id
    }
  }
}


resource "nsxt_firewall_section" "defaultlayer3sect" {
  section_type = "LAYER3"
  stateful     = true 
}


resource "nsxt_firewall_section" "PrivateCloudGaurdrailBlackist" {
  description  = "Private Cloud Default Section provisioned by Terraform"
  display_name = "Private Cloud Default Deny"
  section_type = "LAYER3"
  insert_before = "${nsxt_firewall_section.defaultlayer3sect.id}"
  stateful     = true
   applied_to {
    target_type = "NSGroup"
    target_id   = nsxt_ns_group.PrivateCloud.id
  }

    rule {
    display_name = "Default Deny (Reject)"
    description  = ""
    action       = "REJECT"
    logged       = false
    ip_protocol  = "IPV4"
    source {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.PrivateCloud.id
    }    
    destination {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.PrivateCloud.id
    }
  }
}


