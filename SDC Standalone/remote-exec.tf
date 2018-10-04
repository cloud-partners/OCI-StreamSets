resource "oci_core_instance" "DataCollector" {
    depends_on = ["oci_core_instance.DataCollector"]
	}
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "5m"
        host = "${data.oci_core_vnic.DataCollector_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
      }
      inline = [
	"yum install java-1.8.0-openjdk.x86_64 -y",
	"ulimit -n 32768",
	"wget https://s3-us-west-2.amazonaws.com/archives.streamsets.com/datacollector/3.5.0/rpm/el7/streamsets-datacollector-3.5.0-el7-all-rpms.tar--2018-10-04 15:45:46--  https://s3-us-west-2.amazonaws.com/archives.streamsets.com/datacollector/3.5.0/rpm/el7/streamsets-datacollector-3.5.0-el7-all-rpms.tar",
  	"tar xf streamsets-datacollector-3.5.0-el7-all-rpms.tar",
 	"yum localinstall streamsets-datacollector-3.5.0-1.noarch.rpm",
  	"systemctl start sdc",
  	"echo The default username and password are admin and admin",
  	"echo Browse to http://<system-ip>:18630/"
	]
    }
}

