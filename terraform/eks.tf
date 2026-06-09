#  Security Group for EKS additional access control rules
# This SG is attached to EKS cluster/nodes to control network traffic between bastion and cluster

resource "aws_security_group" "add_sg_eks" {
  name   = "additional-eks-sg"                     # Security group name for EKS additional access rules
  vpc_id = module.vpc.vpc_id                       # Attach security group to the created VPC

  # NGRESS RULES (Inbound traffic to EKS)
  # Controls who can access the EKS cluster from outside
  ingress {
    description = "HTTPS from bastion host"        # Allow HTTPS traffic only from bastion host
    from_port   = 443                              # HTTPS port start
    to_port     = 443                              # HTTPS port end
    protocol    = "tcp"                            # TCP protocol

    security_groups = [aws_security_group.bastion_sg.id]  # Allow traffic only from bastion SG
  }

  # EGRESS RULES (Outbound traffic from EKS)
  # Controls where EKS nodes can send traffic
  egress {
    from_port   = 0                                # Allow all outbound traffic start port
    to_port     = 0                                # Allow all outbound traffic end port
    protocol    = "-1"                             # Allow all protocols outbound
    cidr_blocks = ["0.0.0.0/0"]                    # Allow internet access
  }

  tags = {
    Name = "additional-eks-sg"                    # Tag for identification
  }
}

# EKS Cluster Configuration
# Creates Kubernetes cluster and manages control plane + worker node configuration

module "eks" {
  source  = "terraform-aws-modules/eks/aws"        # Official EKS Terraform module
  version = "~> 21.0"                              # Module version constraint

  name               = "terraform-cluster"         # EKS cluster name
  kubernetes_version = "1.34"                     # Kubernetes version for cluster

  # EKS ADDONS (Core Kubernetes components)
  # These run inside the cluster and provide networking + DNS + identity features
  addons = {
    coredns = {}                                   # DNS resolution inside cluster

    eks-pod-identity-agent = {
      before_compute = true                       # Install before worker nodes start
    }

    kube-proxy = {}                                # Maintains network rules on nodes

    vpc-cni = {
      before_compute = true                       # Handles pod networking in AWS VPC
    }
  }

  # API SERVER ACCESS CONTROL
  endpoint_public_access = false                  # Disable public API endpoint (private cluster)

  # Cluster Admin Access
  enable_cluster_creator_admin_permissions = true  # Grants admin access to Terraform user

  # NETWORK CONFIGURATION
  vpc_id     = module.vpc.vpc_id                  # VPC where cluster is deployed
  subnet_ids = module.vpc.private_subnets         # Worker nodes placed in private subnets

  # EXTRA SECURITY GROUP ATTACHMENT
  additional_security_group_ids = [aws_security_group.add_sg_eks.id]  # Attach custom SG to EKS

  # WORKER NODE GROUPS (EC2 instances running Kubernetes workloads)
  eks_managed_node_groups = {
    example = {

      # AMI TYPE FOR NODES
      ami_type       = "AL2023_x86_64_STANDARD"   # Amazon Linux 2023 optimized for EKS

      # INSTANCE TYPE
      instance_types = ["c7i-flex.large"]         # EC2 instance type for worker nodes

      # AUTO SCALING SETTINGS
      min_size     = 2                            # Minimum worker nodes
      max_size     = 10                           # Maximum worker nodes
      desired_size = 2                            # Desired running nodes

    }
  }

  # TAGGING
  tags = {
    Environment = "dev"                          # Environment name
    Terraform   = "true"                         # Indicates Terraform managed infrastructure
  }
}