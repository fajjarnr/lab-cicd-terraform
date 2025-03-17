locals {
  ec2_ubuntu = <<-EOF
              #!/bin/bash
              sudo hostnamectl set-hostname ubuntu
              sudo apt update
              sudo apt upgrade -y
              sudo apt install podman skopeo pipx unzip -y
              sudo apt install pipx podman-compose -y
              
              # ocp client
              curl -sLO "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.18.1.tar.gz"
              tar xvf openshift-client-linux-4.18.1.tar.gz
              sudo mv oc kubectl /usr/local/bin/
              
              # helm
              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
              
              # aws_cli
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              
              # podman_conf
              REGISTRIES_CONF="/etc/containers/registries.conf"
              echo 'unqualified-search-registries = ["docker.io", "quay.io", "registry.redhat.io", "registry.access.redhat.com"]' | sudo tee -a $REGISTRIES_CONF
              
              # eksctl
              ARCH=amd64
              PLATFORM=$(uname -s)_$ARCH
              curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
              tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
              sudo mv /tmp/eksctl /usr/local/bin

              # terraform
              wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
              sudo apt update && sudo apt install terraform
              EOF
}

module "ubuntu_bastion" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "ubuntu-bastion"

  instance_type          = "m5.large"
  key_name               = "key"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  ami                    = "ami-06650ca7ed78ff6fa"

  associate_public_ip_address = true
  user_data                   = local.ec2_ubuntu

  root_block_device = [
    {
      volume_size = 30
      volume_type = "gp3"
    }
  ]

  depends_on = [module.vpc]

  tags = {
    Terraform = "true"
  }
}
