# AWS Network Load Balancer TCP, TLS, Route 53 with Terraform
## The Task - Infrastructure as a code
### 1. Created 2 EC2 Instances under Auto-Scaling-Group
```
# Autoscaling Group Resource
resource "aws_autoscaling_group" "my_asg" {
  name_prefix = "myasg-"
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier  = module.vpc.private_subnets
  target_group_arns = module.nlb.target_group_arns
  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds  
  # Launch Template
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = aws_launch_template.my_launch_template.latest_version
  }
  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      #instance_warmup = 300 # Default behavior is to use the Auto Scaling Group's health check grace period.
      min_healthy_percentage = 50
    }
    triggers = [ /*"launch_template",*/ "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger
  }  
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }      
}

```
#### 2. Created a NLB
#### 3. Created a Listner on Port 80 on NLB
#### 4. Created Target-Group to send all traffic to Port 31555
```
# Terraform AWS Network Load Balancer (NLB)
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"
  name_prefix = "nlb-"
  load_balancer_type = "network"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  
  #  TCP Listener 
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  #  TLS Listener
  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    },
  ]

  # Target Groups 
  target_groups = [
    {
      name_prefix          = "app-"
      backend_protocol     = "TCP"
      backend_port         = 31555
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    },
  ]
  tags = local.common_tags
}
```
#### 5. Target Type for Target-Group should be all instances under Auto-Scaling-Group created in step 1
```
Please check in 1st step
```
#### 6.1. Schedule Auto-Scaling-Group to be scale down all instances after 18:00 PM CET Mon-Fri
##### Create Scheduled Action-2: Decrease capacity during business hours
```
resource "aws_autoscaling_schedule" "decrease_capacity_5pm" {
  scheduled_action_name  = "decrease-capacity-5pm"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 0
  start_time             = "2030-03-30T21:00:00Z" # Time should be provided in UTC Timezone (4PM UTC = 6PM CET)
  recurrence             = "00 16 * * 1-5"
  autoscaling_group_name = aws_autoscaling_group.my_asg.id
}
```
#### 6.2. Schedule Auto-Scaling-Group to be scale up all instances after 8 AM CET
##### Create Scheduled Action-1: Increase capacity during business hours
```
resource "aws_autoscaling_schedule" "increase_capacity_7am" {
  scheduled_action_name  = "increase-capacity-7am"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
  start_time             = "2030-03-30T11:00:00Z" # Time should be provided in UTC Timezone (6AM UTC = 8AM CET)
  recurrence             = "00 06 * * 1-5"
  autoscaling_group_name = aws_autoscaling_group.my_asg.id 
}
```
#### Written in terraform.

## Acceptance criteria
#### I hope the code is clean and readable
#### I have updated README.md that explains how to use your code and decisions you made
#### Provided deployment instructions
#### Provided some rationale for your design choices (I used $language because..., I used $library because..., etc. )
## Assumptions
1. Can use any open-source tools/language to solve problem
2. Create extra code if needed like infra(scripts) etc in same repo
3. Choose simple applications from internet e.g. nginx, httpd

## Bonus
#### 1. Installed nginx/httpd with sample page
#### 2. When hit the NLB URL on port 80, it connects to EC2 and shows nginx/httpd sample page


## Introduction
- Create [AWS Network Load Balancer using Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest)
- Create TCP Listener
- Create TLS Listener
- Create Target Group

### 07-securitygroup-privatesg.tf
- NLB requires private security group EC2 Instances to have the `ingress_cidr_blocks` as `0.0.0.0/0`
```t
# Before
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]

# After
  ingress_cidr_blocks = ["0.0.0.0/0"] # Required for NLB
```
## 24-NLB-network-loadbalancer.tf
- Create [AWS Network Load Balancer using Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest)
- Create TCP Listener
- Create TLS Listener
- Create Target Group
```t
```
# Terraform AWS Network Load Balancer (NLB)
```
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"
  name_prefix = "nlb-"
  load_balancer_type = "network"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  #security_groups = [module.loadbalancer_sg.this_security_group_id] # Security Groups not supported for NLB
  # TCP Listener 
    http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }  
  ]  

  #  TLS Listener
  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    },
  ]


  # Target Group
  target_groups = [
    {
      name_prefix      = "app-"
      backend_protocol = "TCP"
      backend_port     = 31555
      target_type      = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }      
    },
  ]
  tags = local.common_tags 
}
```
## 25-NLB-network-loadbalancer-outputs.tf
```t
# Terraform AWS Network Load Balancer (NLB) Outputs
output "lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.nlb.lb_id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.nlb.lb_arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.nlb.lb_dns_name
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.nlb.lb_arn_suffix
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.nlb.lb_zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.nlb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.nlb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.nlb.https_listener_arns
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = module.nlb.https_listener_ids
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.nlb.target_group_arns
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.nlb.target_group_arn_suffixes
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.nlb.target_group_names
}
```
## 26-route53-dnsregistration.tf
```
- **Change-1:** Update DNS Name
- **Change-2:** Update `alias name`
- **Change-3:** Update `alias zone_id` 
```t
# DNS Registration 
resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.mydomain.zone_id 
  name    = "nlb.flyahead/org"
  type    = "A"
  alias {
    name                   = module.nlb.lb_dns_name
    zone_id                = module.nlb.lb_zone_id
    evaluate_target_health = true
  }  
}
```
## 22-autoscaling-resource.tf
- Change the module name for `target_group_arns` to `nlb`
```t
# Before
  target_group_arns = module.alb.target_group_arns
# After
  target_group_arns = module.nlb.target_group_arns
```
## Execute Terraform Commands
```t
# Terraform Initialize
terraform init

# Terrafom Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
```
## Verify the AWS resources created
0. Confirm SNS Subscription in your email
1. Verify EC2 Instances
2. Verify Launch Templates (High Level)
3. Verify Autoscaling Group (High Level)
4. Verify Network Load Balancer 
  - TCP Listener
  - TLS Listener
5. Verify Network Load Balancer Target Group 
  - Health Checks - both nodes should be healthy
6. Access and Test
```t
# Access and Test with Port 80 - TCP Listener
http://nlb.flyahead.org
http://nlb.flyahead.org/index.html

# Access and Test with Port 443 - TLS Listener
https://nlb.flyahead.org
https://nlb.flyahead.org/index.html

```

## Step-11: Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve

# Clean-Up Files
rm -rf .terraform*
rm -rf terraform.tfstate*
```
## References
-[Complete NLB - Example](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest/examples/complete-nlb)
