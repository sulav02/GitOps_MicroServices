# Generate a private key using TLS provider and registers it in AWS.
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"        # Generates RSA key pair for SSH access (Asymmetric encryption algorithm)
  rsa_bits  = 4096         # Strong encryption key size (secure for production use)
}

# Register the public key in AWS as an EC2 Key Pair
resource "aws_key_pair" "bastion_keypair" {
  key_name   = "bastion-key"    # Name of key pair in AWS
  public_key = tls_private_key.bastion_key.public_key_openssh # Public key registered in AWS
}

# Save private key locally on machine
resource "local_file" "bastion_private_key" {
  content         = tls_private_key.bastion_key.private_key_pem # Private key content for SSH
  filename        = "bastion-key.pem"      # Local file name
  file_permission = "0400"  # Read-only permission for security
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"            # Security group name
  vpc_id = module.vpc.vpc_id       # VPC where security group is created

# INBOUND RULES (who can connect to bastion)
  ingress {
    description = "SSH from my IP"                                # Allow SSH only from your IP
    from_port   = 22                                               # SSH port start
    to_port     = 22                                               # SSH port end
    protocol    = "tcp"                                            # TCP protocol
# chomp() removes the last newline (\n) or extra line break from a string.
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]   # Your public IP only
  }

# OUTBOUND RULES (what bastion can access)
  egress {
    from_port   = 0              # Allow all outbound traffic start port
    to_port     = 0              # Allow all outbound traffic end port
    protocol    = "-1"           # All protocols allowed outbound
    cidr_blocks = ["0.0.0.0/0"]  # Allow internet access
  }

  tags = {
    Name = "bastion-sg"          # Security group tag name for identification
  }
}

# Bastion Host EC2 Instance
module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"  # EC2 module source

  name          = "bastion-host"                      # EC2 instance name
  ami           = data.aws_ami.ubuntu.id              # Ubuntu AMI ID
  instance_type = "t3.micro"                          # Small instance type
  key_name      = aws_key_pair.bastion_keypair.key_name # SSH key pair name
  monitoring    = true                                # Enable detailed monitoring

# Place bastion in PUBLIC subnet
  subnet_id = module.vpc.public_subnets[0]   # Deploy in public subnet

 # Attach security group (controls SSH access)
  vpc_security_group_ids = [aws_security_group.bastion_sg.id] # Attach security group

  # Required so bastion gets a public IP
  associate_public_ip_address = true                  # Assign public IP

  tags = {
    Terraform   = "true"     # Managed by Terraform
    Environment = "dev"      # Environment tag
    Role        = "bastion"  # Instance role
  }
}