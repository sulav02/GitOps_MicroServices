# Output EKS cluster name after creation
# Used to easily reference or connect kubectl to the cluster
output "cluster_name" {
  value = module.eks.cluster_name
}

# Output bastion host public IP
# Used to SSH into bastion host from local machine
output "bastion_public_ip" {
  value = module.bastion_host.public_ip
}

# Output VPC ID
# Used to verify and reference VPC in other modules or resources
output "vpc_id" {
  value = module.vpc.vpc_id
}