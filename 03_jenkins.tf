# locals {
#   ec2_jenkins = <<-EOF
#               #!/bin/bash
#               sudo hostnamectl set-hostname jenkins
#               sleep 5s
#               sudo apt update
#               sudo apt upgrade -y

#               # java
#               sleep 5s
#               sudo apt install fontconfig openjdk-17-jre -y


#               #jenkins
#               sleep 5s
#               sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
#               echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
#               sudo apt update
#               sudo apt install jenkins -y
#               sleep 5s
#               sudo systemctl enable jenkins
#               sudo systemctl start jenkins

#               # podman
#               sleep 5s
#               sudo apt update
#               sudo apt install podman skopeo -y

#               # oc_client
#               curl -sLO "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.18.1.tar.gz"
#               tar xvf openshift-client-linux-4.18.1.tar.gz
#               sudo mv oc kubectl /usr/local/bin/

#               # helm
#               curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#               # jfrog
#               sleep 5s
#               sudo mkdir -p /usr/share/keyrings;
#               wget -qO - https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/jfrog.gpg;
#               echo "deb [signed-by=/usr/share/keyrings/jfrog.gpg] https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib" | sudo tee /etc/apt/sources.list.d/jfrog.list;
#               sudo apt update
#               sudo apt install jfrog-cli-v2-jf maven -y

#               # podman_conf
#               REGISTRIES_CONF="/etc/containers/registries.conf"
#               echo 'unqualified-search-registries = ["docker.io", "quay.io", "registry.redhat.io", "registry.access.redhat.com"]' | sudo tee -a $REGISTRIES_CONF

#               # trivy
#               curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.58.1

#               # docker
#               sudo apt-get update
#               sudo apt-get install ca-certificates curl -y
#               sudo install -m 0755 -d /etc/apt/keyrings
#               sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
#               sudo chmod a+r /etc/apt/keyrings/docker.asc
#               echo \
#                 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#                 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#                 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#               sudo apt-get update
#               sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
#               sudo usermod -aG docker ubuntu
#               sudo chmod 777 /var/run/docker.sock
#               sudo systemctl enable --now docker
#               EOF
# }

# module "jenkins" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   name = "jenkins"

#   instance_type          = "m5.xlarge"
#   key_name               = "key"
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   subnet_id              = module.vpc.public_subnets[0]
#   ami                    = "ami-06650ca7ed78ff6fa" #ubuntu

#   associate_public_ip_address = true
#   user_data                   = local.ec2_jenkins

#   root_block_device = [
#     {
#       volume_size = 30
#       volume_type = "gp3"
#     }
#   ]

#   depends_on = [module.vpc]

#   tags = {
#     Terraform = "true"
#   }
# }

# module "jenkins_alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name = "jenkins"

#   load_balancer_type         = "application"
#   vpc_id                     = module.vpc.vpc_id
#   subnets                    = module.vpc.public_subnets
#   security_groups            = [module.vpc.default_security_group_id]
#   enable_deletion_protection = false

#   target_groups = {
#     jenkins = {
#       name_prefix      = "jen"
#       backend_protocol = "HTTP"
#       backend_port     = 8080
#       target_type      = "instance"

#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/login?from=%2F"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#       }

#       protocol_version = "HTTP1"
#       target_id        = module.jenkins.id
#       port             = 8080
#       tags = {
#         Name = "jenkins"
#       }
#     }
#   }

#   listeners = {
#     http = {
#       port     = 80
#       protocol = "HTTP"
#       forward = {
#         target_group_key = "jenkins"
#       }
#     }
#   }

#   depends_on = [module.jenkins]

#   tags = {
#     Terraform = "true"
#   }
# }

# resource "aws_route53_record" "jenkins" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "jenkins"
#   type    = "A"

#   alias {
#     name                   = module.jenkins_alb.dns_name
#     zone_id                = module.jenkins_alb.zone_id
#     evaluate_target_health = true
#   }
# }
