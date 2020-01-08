variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "ssh_public_key" {
}

variable "ssh_private_key" {
}

# Choose an Availability Domain
variable "availability_domain" {
  default = "1"
}

variable "instance_image_ocid" {
  type = map(string)

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.4-2018.02.21-1"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaupbfz5f5hdvejulmalhyb6goieolullgkpumorbvxlwkaowglslq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajlw3xfie2t5t52uegyhiq2npx7bqyu4uvi2zyu3w3mqayc2bxmaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7d3fsb6272srnftyi4dphdgfjf6gurxqhmv6ileds7ba3m2gltxq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaa6h6gj6v4n56mqrbgnosskq63blyv2752g36zerymy63cfkojiiq"
  }
}

variable "instance_shape" {
  default = "VM.Standard1.8"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_virtual_network" "sdcVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "sdcVCN"
  dns_label      = "sdcvnc"
}

resource "oci_core_security_list" "sdcSecList" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.sdcVCN.id
  display_name   = "sdcSecList"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 18630
      min = 18630
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "sdcSubnet" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1]["name"]
  cidr_block          = "10.1.20.0/24"
  display_name        = "sdcSubnet"
  dns_label           = "sdcsubnet"
  security_list_ids   = [oci_core_security_list.sdcSecList.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.sdcVCN.id
  route_table_id      = oci_core_virtual_network.sdcVCN.default_route_table_id
  dhcp_options_id     = oci_core_virtual_network.sdcVCN.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "DataCollectorIG" {
  compartment_id = var.compartment_ocid
  display_name   = "DataCollectorIG"
  vcn_id         = oci_core_virtual_network.sdcVCN.id
}

resource "oci_core_default_route_table" "DataCollectorRT" {
  manage_default_resource_id = oci_core_virtual_network.sdcVCN.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.DataCollectorIG.id
  }
}

#Compute

resource "oci_core_instance" "DataCollector" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "DataCollector"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.sdcSubnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "DataCollector"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  timeouts {
    create = "60m"
  }
}

output "SSH_Command" {
  value = <<END
        ssh -i ~/.ssh/id_rsa opc@${data.oci_core_vnic.datacollector_vnic.public_ip_address}
END

}

output "Data_Collector_Console" {
  value = <<END
	http://${data.oci_core_vnic.datacollector_vnic.public_ip_address}:18630/ . The default username and password are admin and admin.
END

}
