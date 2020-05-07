resource "aws_security_group" "postgres_database_security_group" {
  name        = "database-security-group-${var.component}-${var.deployment_identifier}"
  description = "Allow access to ${var.component} PostgreSQL database from private network."
  vpc_id      = var.vpc_id

  tags = {
    Name                 = "sg-database-${var.component}-${var.deployment_identifier}"
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}

resource "aws_security_group_rule" "cidr_allowed" {
  count       = var.private_network_cidr == "" ? 0 : 1
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = split(",", var.private_network_cidr)
  security_group_id = aws_security_group.postgres_database_security_group
}

resource "aws_security_group_rule" "sg_allowed" {
  count                    = length(var.ingress_sg_ids)
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = element(var.ingress_sg_ids, count.index)
  security_group_id = aws_security_group.postgres_database_security_group
}
