# locals {
#   ec2_jboss = <<-EOF
#               #!/bin/bash
#               sudo hostnamectl set-hostname jboss
#               sleep 5s
#               sudo yum install java-11-openjdk-devel unzip -y
#               sleep 5s
#               curl -sLO "https://download1507.mediafire.com/0xy1rgxh8o8g0-gGHJbThs3ZAMMDS0iXHwpeldbTwcHJkYLzUa7oruZ_UUpW8FJbKiiFWdJn9zVYq2gOWncZn5SL1fCXFuDbwiR-cUOH5Ge9O7K-h710l82pG0wUba4-pS3D4jVpJL70rhz9iFSum7czQ1DjqWqWtILM3_CtokQ/oq90v78d8u30w2u/jboss-eap-8.0.0.zip"
#               sleep 5s
#               unzip jboss-eap-8.0.0.zip
#               mv jboss-eap-8.0 jboss
#               sleep 5s
#               sudo setenforce 0
#               sleep 5s
#               sudo chmod +x /home/ec2-user/jboss/bin/standalone.sh
#               sleep 5s
#               export JAVA_HOME=/bin/java
#               export JBOSS_HOME=/home/ec2-user/jboss
#               sleep 5s
#               cd /home/ec2-user/jboss/bin/
#               sudo ./add-user.sh -u admin -p P@ssw0rd123 -g admin
#               sudo ./add-user.sh -u jboss -p P@ssw0rd123 -g admin
#               sleep 5s
#               sudo sed -i 's/$${jboss.bind.address.management:127.0.0.1}/$${jboss.bind.address.management:0.0.0.0}/g' /home/ec2-user/jboss/standalone/configuration/standalone.xml
#               sudo sed -i 's/$${jboss.bind.address:127.0.0.1}/$${jboss.bind.address:0.0.0.0}/g' /home/ec2-user/jboss/standalone/configuration/standalone.xml
#               sleep 5s
#               echo "
#                 [Unit]
#                 Description=JBoss EAP 8
#                 After=network.target

#                 [Service]
#                 User=ec2-user
#                 Group=ec2-user
#                 ExecStart=/home/ec2-user/jboss/bin/standalone.sh
#                 ExecStop=/home/ec2-user/jboss/bin/jboss-cli.sh --connect command=:shutdown
#                 WorkingDirectory=/home/ec2-user/jboss
#                 LimitNOFILE=1024
#                 TimeoutSec=300

#                 [Install]
#                 WantedBy=multi-user.target" | sudo tee /etc/systemd/system/jboss.service
#               sleep 5s
#               sudo systemctl daemon-reload
#               sudo systemctl enable jboss.service
#               sudo systemctl start jboss.service
#               EOF
# }

# resource "random_integer" "subnet_index" {
#   min = 0
#   max = length(module.vpc.public_subnets) - 1
# }

# module "jboss" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   name = "jboss"

#   instance_type          = "m5.2xlarge"
#   key_name               = "key"
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   subnet_id              = element(module.vpc.public_subnets, random_integer.subnet_index.result)
#   ami                    = "ami-0b748249d064044e8" # rhel 9

#   associate_public_ip_address = true
#   user_data                   = local.ec2_jboss

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

# module "jboss_alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name = "jboss"

#   load_balancer_type         = "application"
#   vpc_id                     = module.vpc.vpc_id
#   subnets                    = module.vpc.public_subnets
#   security_groups            = [module.vpc.default_security_group_id]
#   enable_deletion_protection = false

#   target_groups = {
#     jboss = {
#       name_prefix      = "jeb"
#       backend_protocol = "HTTP"
#       backend_port     = 8080
#       target_type      = "instance"

#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#       }

#       protocol_version = "HTTP1"
#       target_id        = module.jboss.id
#       port             = 8080
#       tags = {
#         Name = "jboss"
#       }
#     }

#     jboss-mgmt = {
#       name_prefix      = "jeb"
#       backend_protocol = "HTTP"
#       backend_port     = 9990
#       target_type      = "instance"

#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#       }

#       protocol_version = "HTTP1"
#       target_id        = module.jboss.id
#       port             = 9990
#       tags = {
#         Name = "jboss-mgmt"
#       }
#     }
#   }

#   listeners = {
#     http = {
#       port     = 80
#       protocol = "HTTP"
#       forward = {
#         target_group_key = "jboss"
#       }
#     }
#     mgmnt = {
#       port     = 9990
#       protocol = "HTTP"
#       forward = {
#         target_group_key = "jboss-mgmt"
#       }
#     }
#   }

#   depends_on = [module.jboss]

#   tags = {
#     Terraform = "true"
#   }
# }


# resource "aws_route53_record" "jboss" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "jboss"
#   type    = "A"

#   alias {
#     name                   = module.jboss_alb.dns_name
#     zone_id                = module.jboss_alb.zone_id
#     evaluate_target_health = true
#   }
# }
