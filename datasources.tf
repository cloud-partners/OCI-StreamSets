
# Gets a list of vNIC attachments on the instance
data "oci_core_vnic_attachments" "datacollector_vnics" {
compartment_id = "${var.compartment_ocid}"
availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1],"name")}"
instance_id     = "${oci_core_instance.DataCollector.id}"
}

# Gets the OCID of the first (default) vNIC
data "oci_core_vnic" "datacollector_vnic" {
vnic_id = "${lookup(data.oci_core_vnic_attachments.datacollector_vnics.vnic_attachments[0],"vnic_id")}"
}
