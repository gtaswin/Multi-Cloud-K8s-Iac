# Output the private IPs of the network interfaces
output "private_ips" {
  value = google_compute_instance.vm.*.network_interface.0.network_ip
}