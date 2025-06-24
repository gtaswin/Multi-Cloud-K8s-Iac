# output "endpoint" {
#   value = aws_eks_cluster.k8.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.k8.certificate_authority[0].data
# }

output "nat_gateway_ip" {
  value = aws_eip.public_ip.public_ip
}

output "master_ip" {
  value = aws_instance.vm1[*].private_ip
}

output "slaves_ip" {
  value = aws_instance.vm[*].private_ip
}