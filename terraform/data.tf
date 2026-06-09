# Get your current public IP address from internet
# Used to automatically allow ONLY your IP in Security Groups
# Helps avoid hardcoding IP manually (which changes often)
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Fetch latest Ubuntu AMI from AWS
# We do NOT hardcode AMI IDs because they change frequently
# Ensures we always launch latest Ubuntu 22.04 LTS image
# Improves security (latest patches automatically included)
data "aws_ami" "ubuntu" {
  most_recent = true

  # Filter AMI name to Ubuntu 22.04 (Jammy)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  # Ensure we only get hardware virtualized images (standard AWS type)
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Owner ID of Ubuntu images (Canonical)
  # Prevents pulling fake or untrusted AMIs
  # Ensures image comes only from official Ubuntu publisher
  owners = ["099720109477"]
}