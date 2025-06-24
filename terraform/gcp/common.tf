# Create a GCP network
resource "google_compute_network" "vnet" {
  name                    = join("-", [var.resource_group_name, "vnet"])
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Create a GCP subnet for VMs
resource "google_compute_subnetwork" "subnet" {
  name          = join("-", [var.resource_group_name, "subnet"])
  network       = google_compute_network.vnet.name
  ip_cidr_range = "10.0.1.0/24"
  region        = var.location
  project       = var.project_id
}

# Create a GCP subnet for pods
resource "google_compute_subnetwork" "subnet_pod" {
  name          = join("-", [var.resource_group_name, "subnet-pod"])
  network       = google_compute_network.vnet.name
  ip_cidr_range = "10.0.3.0/24"
  region        = var.location
  project       = var.project_id
}

resource "google_compute_address" "public_ip" {
  name         = join("-", [var.resource_group_name, "public-ip"])
  description  = "My Static Public IP Address"
  project      = var.project_id
  region       = var.location  # Replace with your desired region
  address_type = "EXTERNAL"
}

# Allow SSH traffic from the specific public IP
resource "google_compute_firewall" "ssh" {
  name    = join("-", [var.resource_group_name, "ssh"])
  network = google_compute_network.vnet.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow traffic from any source IP to the public IP address
  source_ranges = ["0.0.0.0/0"]  # This will allow traffic from any IP address

  # Specify that the destination IP should match the assigned public IP
  destination_ranges = [google_compute_address.public_ip.address]
}

# Allow all internal traffic within the VNet
resource "google_compute_firewall" "internal" {
  name    = join("-", [var.resource_group_name, "internal"])
  network = google_compute_network.vnet.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  destination_ranges = ["0.0.0.0/0"]
}