resource "aws_security_group" "this" {
  name_prefix = "${var.sg_name}-"
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name        = var.sg_name
    Component   = var.component_type
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  count = length(var.ingress_rules)

  security_group_id = aws_security_group.this.id
  
  from_port   = var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].to_port
  ip_protocol = var.ingress_rules[count.index].protocol
  
  cidr_ipv4                    = var.ingress_rules[count.index].cidr_blocks != null ? join(",", var.ingress_rules[count.index].cidr_blocks) : null
  referenced_security_group_id = var.ingress_rules[count.index].security_group_ids != null ? var.ingress_rules[count.index].security_group_ids[0] : null
  
  description = var.ingress_rules[count.index].description

  tags = {
    Name        = "${var.sg_name}-ingress-${count.index + 1}"
    Component   = var.component_type
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = length(var.egress_rules)

  security_group_id = aws_security_group.this.id
  
  from_port   = var.egress_rules[count.index].from_port
  to_port     = var.egress_rules[count.index].to_port
  ip_protocol = var.egress_rules[count.index].protocol
  
  cidr_ipv4                    = var.egress_rules[count.index].cidr_blocks != null ? join(",", var.egress_rules[count.index].cidr_blocks) : null
  referenced_security_group_id = var.egress_rules[count.index].security_group_ids != null ? var.egress_rules[count.index].security_group_ids[0] : null
  
  description = var.egress_rules[count.index].description

  tags = {
    Name        = "${var.sg_name}-egress-${count.index + 1}"
    Component   = var.component_type
    Environment = var.environment
    Project     = var.project_name
  }
}
