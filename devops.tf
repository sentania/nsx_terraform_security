####Allow RDP
resource "nsxt_policy_group" "AllowRDP" {
  display_name = "Allow RDP"
  description  = "Allow RDP Group provisioned by Terraform"
  criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "AllowRDP|Role"
      }
    }
    tag {
        scope = "AllowRDP"
        tag   = "Role"
    }
}

resource "nsxt_policy_service" "RDPService" {
  description  = "RDP Serivces provisioned by Terraform"
  display_name = "RDP Services"

  l4_port_set_entry {
    display_name      = "RDP Server Services"
    description       = "TCP port 3389"
    protocol          = "TCP"
    destination_ports = [ "3389" ]
  }
}

###END RDP Delcaration
resource "nsxt_policy_group" "AllowSSH" {
  display_name = "Allow SSH"
  description  = "Allow SSH Group provisioned by Terraform"
  criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "AllowSSH|Role"
      }
    }
    tag {
        scope = "AllowSSH"
        tag   = "Role"
    }
}

resource "nsxt_policy_group" "MySQLClients" {
  display_name = "MySQLClients"
  description  = "MySQLClients Group provisioned by Terraform"
  criteria {
      condition {
          key         = "Tag"
          member_type = "SegmentPort"
          operator    = "EQUALS"
          value       = "MySQLClient|Role"
      }
    }
    tag {
        scope = "MySQLClient"
        tag   = "Role"
    }
}

resource "nsxt_policy_group" "MySQLServers" {
  display_name = "MySQLServers"
  description  = "MySQLServers Group provisioned by Terraform"
    criteria {
        condition {
            key         = "Tag"
            member_type = "SegmentPort"
            operator    = "EQUALS"
            value       = "MySQLServer|Role"
        }
    }
    tag {
    scope = "MySQLServer"
    tag   = "Role"
  }
}

resource "nsxt_policy_group" "WebServers" {
    display_name = "WebServers"
    description  = "WebServers Group provisioned by Terraform"
    criteria {
        condition {
            key         = "Tag"
            member_type = "SegmentPort"
            operator    = "EQUALS"
            value       = "WebServer|Role"
        }
    }
    tag {
        scope = "WebServer"
        tag   = "Role"
    }
}

resource "nsxt_policy_group" "MSSQLServers" {
    display_name = "MSSQL Servers"
    description  = "MSSQL Servers Group provisioned by Terraform"
    criteria {
        condition {
            key         = "Tag"
            member_type = "SegmentPort"
            operator    = "EQUALS"
            value       = "MSSQLServer|Role"
        }
    }
    tag {
        scope = "MSSQLServer"
        tag   = "Role"
    }
}

resource "nsxt_policy_group" "MSSQLClients" {
    display_name = "MSSQL Clients"
    description  = "MSSQL Clients Group provisioned by Terraform"
    criteria {
        condition {
            key         = "Tag"
            member_type = "SegmentPort"
            operator    = "EQUALS"
            value       = "MSSQLClient|Role"
        }
    }
    tag {
        scope = "MSSQLClient"
        tag   = "Role"
    }
}

resource "nsxt_policy_service" "WebServerServices" {
  description  = "Web Server Serivces provisioned by Terraform"
  display_name = "Web Server Services"

  l4_port_set_entry {
    display_name      = "Web Server Services"
    description       = "TCP port 80 and 443"
    protocol          = "TCP"
    destination_ports = [ "80", "443" ]
  }
  
}

resource "nsxt_policy_service" "MySQLServices" {
  description  = "MySQL Serivces provisioned by Terraform"
  display_name = "MySQL Services"

  l4_port_set_entry {
    display_name      = "MySQL Server Services"
    description       = "TCP port 3306"
    protocol          = "TCP"
    destination_ports = [ "3306" ]
  }
}

resource "nsxt_policy_service" "MSSQLServices" {
  description  = "MSSQL Serivces provisioned by Terraform"
  display_name = "MSSQL Services"

  l4_port_set_entry {
    display_name      = "MSSQL Server Services"
    description       = "TCP port 1433"
    protocol          = "TCP"
    destination_ports = [ "1433" ]
  }
}

resource "nsxt_policy_service" "SSHService" {
  description  = "SSH Serivces provisioned by Terraform"
  display_name = "SSH Services"

  l4_port_set_entry {
    display_name      = "SSH Server Services"
    description       = "TCP port 22"
    protocol          = "TCP"
    destination_ports = [ "22" ]
  }
}

resource "nsxt_policy_security_policy" "PrivateCloudPolicies" {
  description  = "Private Cloud Blueprint Policies Section provisioned by Terraform"
  display_name = "Private Cloud Blueprint Policies"
  category = "Application"
  rule {
    display_name = "Web Traffic"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    services = [nsxt_policy_service.WebServerServices.path]
    destination_groups = [nsxt_policy_group.WebServers.path]
    scope = [nsxt_policy_group.WebServers.path]
  }
    rule {
    display_name = "MySQL Traffic"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    services = [nsxt_policy_service.MySQLServices.path]
    source_groups = [nsxt_policy_group.MySQLClients.path]
    destination_groups = [nsxt_policy_group.MySQLServers.path]
    scope = [nsxt_policy_group.MySQLClients.path,nsxt_policy_group.MySQLServers.path]
  }

    rule {
    display_name = "MySQL Traffic"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    services = [nsxt_policy_service.MSSQLServices.path]
    source_groups = [nsxt_policy_group.MSSQLClients.path]
    destination_groups = [nsxt_policy_group.MSSQLServers.path]
    scope = [nsxt_policy_group.MySQLClients.path,nsxt_policy_group.MySQLServers.path]
  }

    rule {
    display_name = "SSH Traffic"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    services = [nsxt_policy_service.SSHService.path]
    destination_groups = [nsxt_policy_group.AllowSSH.path]
    scope = [nsxt_policy_group.AllowSSH.path]
  }
      rule {
    display_name = "RDP Traffic"
    description  = ""
    action       = "ALLOW"
    ip_version  = "IPV4"
    services = [nsxt_policy_service.RDPService.path]
    destination_groups = [nsxt_policy_group.AllowRDP.path]
    scope = [nsxt_policy_group.AllowRDP.path]
  }
}