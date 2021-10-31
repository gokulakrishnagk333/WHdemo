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
resource "aws_autoscaling_schedule" "decrease_capacity_6pm" {
  scheduled_action_name  = "decrease-capacity-6pm"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 0
  start_time             = "2030-03-30T16:00:00Z" # Time should be provided in UTC Timezone (4PM UTC = 6PM CET)
  recurrence             = "00 16 * * 1-5"
  autoscaling_group_name = aws_autoscaling_group.my_asg.id
}
```
#### 6.2. Schedule Auto-Scaling-Group to be scale up all instances after 8 AM CET
##### Create Scheduled Action-1: Increase capacity during business hours
```
resource "aws_autoscaling_schedule" "increase_capacity_8am" {
  scheduled_action_name  = "increase-capacity-8am"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
  start_time             = "2030-03-30T06:00:00Z" # Time should be provided in UTC Timezone (6AM UTC = 8AM CET)
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


## Additional Bonus I have attached NLB with Route53
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
## Clean-Up
```t
# Terraform Destroy
terraform destroy -auto-approve

```
## References
-[Complete NLB - Example](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest/examples/complete-nlb)
