data "aws_ami" "image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.storage_image_offer}*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  #  owners = ["aws-marketplace"]
}

resource "aws_key_pair" "aws_ssh_key" {
  key_name   = join("-", [var.resource_group_name, "aws-ssh-key"])
  public_key = var.ssh_public_key
  tags = {
    Name          = join("-", [var.resource_group_name, "ssh-key"])
    ResourceGroup = var.resource_group_name
  }
}

#VM1
# Create virtual machines
resource "aws_instance" "vm1" {
  count = 1
  # iam_instance_profile   = aws_iam_instance_profile.master_profile.name
  network_interface {
    network_interface_id = aws_network_interface.vm_nic_1.id
    device_index         = 0
  }

  instance_type = var.vm_size_master
  ami           = data.aws_ami.image.id

  root_block_device {
    volume_type = "gp3"
    volume_size = var.vm_disk_size_gb_master
    encrypted = true
  }

  key_name = aws_key_pair.aws_ssh_key.key_name

  # user_data = <<-EOF
  #      #!/bin/bash
  #      sudo adduser --disabled-password --gecos '' "${var.vm_admin_username}"
  #      sudo mkdir -p "/home/${var.vm_admin_username}/.ssh"
  #      sudo touch "/home/${var.vm_admin_username}/.ssh/authorized_keys"
  #      sudo echo "${var.ssh_public_key}" > authorized_keys
  #      sudo mv authorized_keys "/home/${var.vm_admin_username}/.ssh"
  #      sudo chown -R "${var.vm_admin_username}:${var.vm_admin_username}" "/home/${var.vm_admin_username}/.ssh"
  #      sudo chmod 700 "/home/${var.vm_admin_username}/.ssh"
  #      sudo chmod 600 "/home/${var.vm_admin_username}/.ssh/authorized_keys"
  #      sudo usermod -aG sudo "${var.vm_admin_username}"
  #      EOF

  tags = {
    Name          = join("-", [var.resource_group_name, "vm1"])
    ResourceGroup = var.resource_group_name
  }
}

# Create Other VMs
resource "aws_instance" "vm" {
  count = var.vm_count - 1
  network_interface {
    network_interface_id = aws_network_interface.vm_nic[count.index].id
    device_index         = 0
  }

  instance_type = var.vm_size_slave
  ami           = data.aws_ami.image.id

  root_block_device {
    volume_type = "gp3"
    volume_size = var.vm_disk_size_gb_slave
    encrypted = true
  }

  key_name = aws_key_pair.aws_ssh_key.key_name

  #  user_data = <<-EOF
  #        #!/bin/bash
  #        sudo adduser --disabled-password --gecos '' "${var.vm_admin_username}"
  #        sudo mkdir -p "/home/${var.vm_admin_username}/.ssh"
  #        sudo touch "/home/${var.vm_admin_username}/.ssh/authorized_keys"
  #        sudo echo "${var.ssh_public_key}" > authorized_keys
  #        sudo mv authorized_keys "/home/${var.vm_admin_username}/.ssh"
  #        sudo chown -R "${var.vm_admin_username}:${var.vm_admin_username}" "/home/${var.vm_admin_username}/.ssh"
  #        sudo chmod 700 "/home/${var.vm_admin_username}/.ssh"
  #        sudo chmod 600 "/home/${var.vm_admin_username}/.ssh/authorized_keys"
  #        sudo usermod -aG sudo "${var.vm_admin_username}"
  #        EOF

  tags = {
    Name          = join("-", [var.resource_group_name, "vm${count.index + 2}"])
    ResourceGroup = var.resource_group_name
  }
}

# resource "aws_iam_instance_profile" "master_profile" {
#   name = "master_profile"
#   role = aws_iam_role.node-role.name
# }
