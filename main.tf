# Configure the VMware NSX-T Provider
provider "nsxt" {
    host = var.nsxIP
    username = var.nsxUser
    password = var.nsxPassword
    allow_unverified_ssl = true
}


