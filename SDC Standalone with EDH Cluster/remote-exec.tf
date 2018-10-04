resource "null_resource" "cdh-setup" {
    depends_on = ["oci_core_instance.UtilityNode","oci_core_instance.MasterNode","oci_core_instance.WorkerNode","oci_core_instance.Bastion","oci_core_instance.DataCollector"]
    provisioner "file" {
      source = "../scripts/"
      destination = "/home/opc/"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
    }
    }
    provisioner "file" {
      source = "/Users/michaelcarley/Desktop/SSH_Keys/oracle_terraform/id_rsa"
      destination = "/home/opc/.ssh/id_rsa"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
    }
    }
    provisioner "file" {
      source = "../scripts/startup.sh"
      destination = "/home/opc/startup.sh"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
    }
    }
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
      }
      inline = [
	"chown opc:opc /home/opc/.ssh/id_rsa",
	"chmod 0600 /home/opc/.ssh/id_rsa",
	"chmod +x /home/opc/*.sh",
	"./home/opc/start.sh",
	"echo SCREEN SESSION RUNNING ON BASTION AS ROOT"
	]
    }
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.DataCollector_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
      }
      inline = [
  "wget https://s3-us-west-2.amazonaws.com/archives.streamsets.com/datacollector/3.5.0/rpm/el7/streamsets-datacollector-3.5.0-el7-all-rpms.tar--2018-10-04 15:45:46--  https://s3-us-west-2.amazonaws.com/archives.streamsets.com/datacollector/3.5.0/rpm/el7/streamsets-datacollector-3.5.0-el7-all-rpms.tar",
  "tar xf streamsets-datacollector-3.5.0-el7-all-rpms.tar",
  "yum localinstall streamsets-datacollector-3.5.0-1.noarch.rpm",
  "systemctl start sdc",
  "echo The default username and password are admin and admin",
  "echo Browse to http://<system-ip>:18630/"
  ]
    }
}
