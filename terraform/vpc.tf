module "vpc" {
  source = "terraform-aws-modules/vpc/aws"   # Official Terraform AWS VPC module

  name = "test-vpc-01"                       # Name of the VPC
  cidr = "10.0.0.0/16"                       # CIDR block for entire VPC network

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]  # Availability Zones for high availability
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Private subnets (backend, apps, DB)
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"] # Public subnets (load balancers, bastion)

  enable_nat_gateway = true                 # Allows private subnet instances to access internet
  enable_vpn_gateway  = false               # Disable VPN gateway (not needed for this setup)
  single_nat_gateway  = true                # Use one NAT gateway to reduce cost
  map_public_ip_on_launch = true            # Auto-assign public IPs in public subnets

  tags = {
    Terraform   = "true"                    # Marks resources as managed by Terraform
    Environment = "dev"                     # Environment tag for identification
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"          # Marks subnets for external load balancers (EKS/ALB)
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1" # Marks subnets for internal load balancers
  }
}