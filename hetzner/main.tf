## - main.tf -

# - variables -
variable "count_nodes" {
  description = "the amount of the yugabytesdb nodes"
  default     = 1
}
variable "hz_image" {
  description = "the os images used for nodes"
  default     = "ubuntu-18.04"
}
variable "hz_flavor" {
  description = "the vm flavor used for nodes"
  default     = "cx11"
}

# our ssh pub keys
# see https://www.terraform.io/docs/providers/hcloud/r/ssh_key.html
resource "hcloud_ssh_key" "sshpubkey" {
  name       = "session-sshpubkey"
  public_key = file("~/.ssh/id_rsa.pub")
}

# internal network
# https://www.terraform.io/docs/providers/hcloud/r/server_network.html
resource "hcloud_network" "net" {
  name     = "net"
  ip_range = "10.0.0.0/8"
}
# internal subnet
# see https://www.terraform.io/docs/providers/hcloud/r/network_subnet.html
resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Create a new yugabytedb node
resource "hcloud_server" "yb_node" {
  count       = var.count_nodes
  name        = "yb${count.index}"
  image       = var.hz_image
  server_type = var.hz_flavor
  ssh_keys    = [hcloud_ssh_key.sshpubkey.name, ]

  connection {
    host = self.ipv4_address
    user = "root"
  }

  # see https://www.terraform.io/docs/provisioners/remote-exec.html
  provisioner "remote-exec" {
    inline = [
      # fix the python interpreter, ubuntu 18.04 shipps a python3
      "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10",
      "curl -sfL https://downloads.yugabyte.com/yugabyte-2.3.0.0-linux.tar.gz | tar xzf - -C /opt/"
    ]
  }
}
# networking part
resource "hcloud_server_network" "nw_yb_node" {
  depends_on = [hcloud_server.yb_node, ]
  count      = var.count_nodes
  server_id  = hcloud_server.yb_node[count.index].id
  network_id = hcloud_network.net.id
}

# - outputs - 
# e.g for ssh -l root $(terraform output -json | jq -r '.nodes_ip.value[0]' )
output "nodes_ip" {
  value = hcloud_server.yb_node.*.ipv4_address
}
