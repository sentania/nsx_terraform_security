# Configure the VMware NSX-T Provider
provider "nsxt" {
    host = var.nsxIP
    username = var.nsxUser
    password = var.nsxPassword
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

resource "nsxt_ip_set" "Internet" {
  description  = "Internet IPs provisioned by Terraform"
  display_name = "Internet IPs"
  ip_addresses = ["1.0.0.0/8","3.0.0.0/8","4.0.0.0/6", "8.0.0.0/7", "11.0.0.0/8", "11.0.0.0/8", "12.0.0.0/6", "16.0.0.0/4", "32.0.0.0/3", "64.0.0.0/2", "128.0.0.0/3", "160.0.0.0/5", "168.0.0.0/6", "172.0.0.0/12", "172.32.0.0/11", "172.64.0.0/10", "172.128.0.0/9", "173.0.0.0/8", "174.0.0.0/7", "176.0.0.0/4", "192.0.0.0/9", "192.128.0.0/11", "192.160.0.0/13", "192.169.0.0/16", "192.170.0.0/15", "192.172.0.0/14", "192.176.0.0/12", "192.192.0.0/10", "193.0.0.0/8", "194.0.0.0/7", "196.0.0.0/6", "200.0.0.0/5", "208.0.0.0/4"]
}

resource "nsxt_ip_set" "PrivateIPs" {
  description  = "Private IPs provisioned by Terraform"
  display_name = "Private IP"
  ip_addresses = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
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
    display_name = "Open inside Sandbox"
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
    display_name = "Private Cloud to Sandbox"
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
      target_id   = nsxt_ns_group.Sandbox.id
    }
  }
  rule {
    display_name = "Any to Sandbox"
    description  = ""
    action       = "ALLOW"
    logged       = false
    ip_protocol  = "IPV4"
    destination {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.Sandbox.id
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
    destination {
      target_type = "NSGroup"
      target_id   = nsxt_ns_group.PrivateCloud.id
    }
  }
}
