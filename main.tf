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

resource "nsxt_policy_group" "SharedServices" {
  display_name = "Shared Services"
  description  = "Shared Services Group provisioned by Terraform"
  criteria {
    ipaddress_expression {
      ip_addresses = ["10.100.100.30", "10.101.100.30", "10.100.0.136"]
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

resource "nsxt_policy_group" "InternetCIDR" {
  display_name = "Internet"
  description  = "Internet Group provisioned by Terraform"
  criteria {
    ipaddress_expression {
      ip_addresses = ["1.0.0.0/8","3.0.0.0/8","4.0.0.0/6", "8.0.0.0/7", "11.0.0.0/8", "11.0.0.0/8", "12.0.0.0/6", "16.0.0.0/4", "32.0.0.0/3", "64.0.0.0/2", "128.0.0.0/3", "160.0.0.0/5", "168.0.0.0/6", "172.0.0.0/12", "172.32.0.0/11", "172.64.0.0/10", "172.128.0.0/9", "173.0.0.0/8", "174.0.0.0/7", "176.0.0.0/4", "192.0.0.0/9", "192.128.0.0/11", "192.160.0.0/13", "192.169.0.0/16", "192.170.0.0/15", "192.172.0.0/14", "192.176.0.0/12", "192.192.0.0/10", "193.0.0.0/8", "194.0.0.0/7", "196.0.0.0/6", "200.0.0.0/5", "208.0.0.0/4"]
    }
  }
}

resource "nsxt_policy_group" "PrivateIPs" {
  display_name = "Private IPs"
  description  = "Private IPs Group provisioned by Terraform"
  criteria {
    ipaddress_expression {
      ip_addresses = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    }
  }
}

resource "nsxt_policy_security_policy" "PrivateCloudGaurdrail" {
  description  = "Private Cloud Gaurdrails Section provisioned by Terraform"
  display_name = "Private Cloud Gaurdrails"
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

resource "nsxt_policy_security_policy" "PrivateCloudGaurdrailBlackist" {
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
