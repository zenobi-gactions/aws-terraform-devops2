# resource "aws_route53_zone" "andynze" {
#   name = "andynze.com"
# }

# resource "aws_route53_record" "grafana" {
#   zone_id = aws_route53_zone.andynze.zone_id
#   name    = "grafana.andynze.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.grafana.dns_name
#     zone_id                = aws_lb.grafana.zone_id
#     evaluate_target_health = true
#   }
#   depends_on = [aws_lb.argocd]
# }

# resource "aws_route53_record" "argocd" {
#   zone_id = aws_route53_zone.andynze.zone_id
#   name    = "argocd.andynze.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.argocd.dns_name
#     zone_id                = aws_lb.argocd.zone_id
#     evaluate_target_health = true
#   }
#   depends_on = [aws_lb.argocd]
# }

################################
#### AWS ACM Certificate

# resource "aws_acm_certificate" "andynze_cert" {
#   domain_name       = "andynze.com"
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "grafana.andynze.com",
#     "argocd.andynze.com"
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "andynze-cert"
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.andynze_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }

#   zone_id = aws_route53_zone.andynze.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 300
# }

# resource "aws_acm_certificate_validation" "andynze_cert_validation" {
#   certificate_arn         = aws_acm_certificate.andynze_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

#   depends_on = [aws_route53_record.cert_validation]
# }

################################
#### AWS Load Balancer Security Group Management

# data "aws_subnets" "selected" {
#   filter {
#     name   = "vpc-id"
#     values = ["var.vpc_id"]  # Replace with your VPC ID
#   }
# }

# # Create Security Group for the Load Balancers
# resource "aws_security_group" "lb_sg" {
#   name        = "lb_sg"
#   description = "Security group for load balancers"
#   vpc_id      = var.vpc_id  # Replace with your VPC ID

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Create an ALB for Grafana
# resource "aws_lb" "grafana" {
#   name               = "grafana-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [var.security_group_id]
#   subnets            = var.public_subnet_ids # ["subnet-12345678", "subnet-87654321"]  # Replace with your subnet IDs

#   enable_deletion_protection = false
#   tags = {
#     Environment = "dev"
#   }
# }

# # Create an ALB for ArgoCD
# resource "aws_lb" "argocd" {
#   name               = "argocd-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [var.security_group_id]
#   subnets            = var.public_subnet_ids # ["subnet-12345678", "subnet-87654321"]  # Replace with your subnet IDs

#   enable_deletion_protection = false
#   tags = {
#     Environment = "dev"
#   }
# }

# # Create Target Group for Grafana
# resource "aws_lb_target_group" "grafana" {
#   name     = "grafana-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
#   target_type = "instance"
# }

# # Create Target Group for ArgoCD
# resource "aws_lb_target_group" "argocd" {
#   name     = "argocd-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
#   target_type = "instance"
# }

# # Create Listener for Grafana ALB
# resource "aws_lb_listener" "grafana" {
#   load_balancer_arn = aws_lb.grafana.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.grafana.arn
#   }
# }

# # Create Listener for ArgoCD ALB
# resource "aws_lb_listener" "argocd" {
#   load_balancer_arn = aws_lb.argocd.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.argocd.arn
#   }
# }


# resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller_role.arn
#     }
#   }
# }
################################################################

# # Retrieve an existing ACM Certificate by domain name
# data "aws_acm_certificate" "andynze_cert" {
#   domain = "andynze.com"

#   # Ensure we're using the issued certificate
#   statuses = ["ISSUED"]
# }

# output "acm_certificate_arn" {
#   value = data.aws_acm_certificate.andynze_cert.arn
# }
################################################################

# resource "kubernetes_ingress_v1" "grafana_ingress" {
#   metadata {
#     name      = "grafana-ingress"
#     namespace = "monitoring"
#     annotations = {
#       "kubernetes.io/ingress.class"                = "alb"
#       "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
#       "alb.ingress.kubernetes.io/target-type"      = "ip"
#       "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{"HTTP": 80}, {"HTTPS": 443}])
#       "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:us-east-1:${var.account_id}:certificate/cdbe801b-e440-4bf7-a69e-71345ea35b4c"
#     }
#   }

#   spec {
#     rule {
#       host = "grafana.andynze.com"
#       http {
#         path {
#           path     = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "grafana"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [helm_release.aws_load_balancer_controller]
# }

# resource "kubernetes_ingress_v1" "argocd_ingress" {
#   metadata {
#     name      = "argocd-ingress"
#     namespace = "argocd"
#     annotations = {
#       "kubernetes.io/ingress.class"                = "alb"
#       "alb.ingress.kubernetes.io/target-type"      = "ip"
#       "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
#       "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{"HTTP": 80}, {"HTTPS": 443}])
#       "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:us-east-1:${var.account_id}:certificate/cdbe801b-e440-4bf7-a69e-71345ea35b4c"# data.aws_acm_certificate.andynze_cert.arn
#     }
#   }

#   spec {
#     rule {
#       host = "argocd.andynze.com"

#       http {
#         path {
#           path     = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "argo-cd-argocd-server"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [helm_release.aws_load_balancer_controller]
# }


################################################################

