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

// See https://docs.cloud.oracle.com/iaas/images/image/cc839b42-1566-4d87-92c3-dbb5945299c7/
// Oracle-provided image "Oracle-Linux-7.7-2019.12.18-0"
variable "instance_image_ocid" {
  type = "map"
  default = {
    ap-mumbai-1    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaka7f3qhfuobx2s7dqfgbcx5klllh5xlflbgzb5pymqsnuphehk2a",
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaw52bcejclqwpqchgfx7fhuj4f4smruqxdywwn3uy2xhmhh6bzpza",
    ap-sydney-1    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaazy24niulp5e5a5oyaadjrwnwoa2g6f2hay2f26dqy63pn5sljjma",
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaarl7op6ken6hpevfwuevfnt6ic3tlhitu7pct2py5uxdzyvqb5mkq",
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaa6wg3hkw7qxwgysuv5c3fuhtyau5cps4ktmjgxvdtxk6ajtf23fcq",
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaalljvzqt3aw7cwpls3oqx7dyrcuntqfj6xn3a2ul3jiuby27lqdxa",
    eu-zurich-1    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaf2fwfgbpxz2g3boettl3q6tow7efs34v2t2t5r45yuydvkqm32ha",
    sa-saopaulo-1  = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaatwrc37cesjtgx3gm4vzq6ocpedgzxjystewc2a7stnv2ydcoiquq",
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaagwdcgcw4squjusjy4yoyzxlewn6omj75f2xur2qpo7dgwexnzyhq",
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaaxrcvnpfxfsyzv3ytuu6swalnbmocneej6yj4nr4vbcoufgmfpwqq",
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaactxf4lnfjj6itfnblee3g3uckamdyhqkwfid6wslesdxmlukqvpa"
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
    protocol    = "all"
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
    user_data = base64encode(
      join(
        "\n",
        [
          "#!/usr/bin/env bash",
          file("./scripts/config.sh")
        ],
      ),
    )
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
