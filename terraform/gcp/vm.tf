resource "google_compute_instance" "vm" {
  count        = var.vm_count
  name         = join("-", [var.resource_group_name, "vm${count.index + 1}"])
  machine_type = count.index == 0 ? var.vm_size_master : var.vm_size_slave
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.storage_image
      size  = count.index == 0 ? var.vm_disk_size_gb_master : var.vm_disk_size_gb_slave
      type  = var.storage_os_disk_managed_disk_type  # Specify the disk type here
    }
  }

  network_interface {
    network    = google_compute_network.vnet.name
    subnetwork = google_compute_subnetwork.subnet.name

    # Assign specific private IP addresses to instances
    network_ip = "10.0.1.${count.index + 4}"

    # Only assign a public IP to the first instance
    access_config {
      nat_ip = count.index == 0 ? google_compute_address.public_ip.address : null
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Startup script executed."

    # Create the specified admin user
    useradd -m -s /bin/bash ${var.vm_admin_username}

    # Add admin user to sudoers with passwordless sudo access
    echo "${var.vm_admin_username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${var.vm_admin_username}
    chmod 440 /etc/sudoers.d/${var.vm_admin_username}

    # Set SSH key for the admin user
    mkdir -p /home/${var.vm_admin_username}/.ssh
    echo "${var.ssh_public_key}" > /home/${var.vm_admin_username}/.ssh/authorized_keys
    chown -R ${var.vm_admin_username}:${var.vm_admin_username} /home/${var.vm_admin_username}/.ssh
    chmod 700 /home/${var.vm_admin_username}/.ssh
    chmod 600 /home/${var.vm_admin_username}/.ssh/authorized_keys

    # Add any custom configuration or installation commands here
  EOT

  tags = ["ssh"]
}
