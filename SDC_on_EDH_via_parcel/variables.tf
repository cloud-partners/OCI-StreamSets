# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/cloud-partners/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "compartment_ocid" {}

# Required by the OCI Provider
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# Key used to SSH to OCI VMs
variable "ssh_public_key" {}
variable "ssh_private_key" {}

# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# You can modify these.
# ---------------------------------------------------------------------------------------------------------------------

variable "AD" {
  default = "2"
}

variable "nodecount" {
  default = "5"
}

variable "MasterNodeCount" {
  default = "2"
}

variable "boot_volume_size" {
  default = "256"
}

variable "blocksize_in_gbs" {
  default = "1024"
}

variable "BastionInstanceShape" {
  default = "VM.Standard2.8"
}

variable "MasterInstanceShape" {
  default = "VM.Standard2.8"
}

variable "WorkerInstanceShape" {
  default = "VM.Standard2.8"
}

variable "ssh_keypath" {
  default = "/home/opc/.ssh/id_rsa"
}

# ---------------------------------------------------------------------------------------------------------------------
# Constants
# You probably don't need to change these.
# ---------------------------------------------------------------------------------------------------------------------

// See https://docs.us-phoenix-1.oraclecloud.com/images/
// Oracle-provided image "CentOS-7.5-2018.06.22-0"
variable "InstanceImageOCID" {
  type = "map"
  default = {
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaasdvfvvgzjhqpuwmjbypgovachdgwvcvus5n4p64fajmbassg2pqa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa5o7kjzy7gqtmu5pxuhnh6yoi3kmzazlk65trhpjx5xg3hfbuqvgq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaa74er3gyrjg3fiesftpc42viplbhp7gdafqzv33kyyx3jrazruta"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaapnnv2phiyw7apcgtg6kmn572b2mux56ll6j6mck5xti3aw4bnwrq"
  }
}
