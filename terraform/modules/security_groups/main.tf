# Module Security Groups — filtrage par zone
# DMZ : 80/443 depuis Internet, SSH depuis l'IP d'admin uniquement
# Interne : joignable UNIQUEMENT depuis la DMZ (aucune exposition Internet)

# --- Security Group DMZ ---
resource "aws_security_group" "dmz" {
  name        = "${var.project}-sg-dmz"
  description = "DMZ : web public + SSH admin restreint"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project}-sg-dmz"
    Project = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "dmz_http" {
  security_group_id = aws_security_group.dmz.id
  description       = "HTTP public"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dmz_https" {
  security_group_id = aws_security_group.dmz.id
  description       = "HTTPS public"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dmz_ssh_admin" {
  security_group_id = aws_security_group.dmz.id
  description       = "SSH depuis l'IP d'administration uniquement"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.admin_cidr # ex. 203.0.113.4/32 — JAMAIS 0.0.0.0/0
}

resource "aws_vpc_security_group_egress_rule" "dmz_all_out" {
  security_group_id = aws_security_group.dmz.id
  description       = "Sortie autorisee"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# --- Security Group interne ---
resource "aws_security_group" "internal" {
  name        = "${var.project}-sg-internal"
  description = "Zone interne : joignable uniquement depuis la DMZ"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.project}-sg-internal"
    Project = var.project
  }
}

# SSH depuis la DMZ (rebond d'administration)
resource "aws_vpc_security_group_ingress_rule" "internal_ssh_from_dmz" {
  security_group_id            = aws_security_group.internal.id
  description                  = "SSH depuis la DMZ"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.dmz.id
}

# Port applicatif depuis la DMZ uniquement (ex. backend sur 8080)
resource "aws_vpc_security_group_ingress_rule" "internal_app_from_dmz" {
  security_group_id            = aws_security_group.internal.id
  description                  = "Port applicatif depuis la DMZ"
  from_port                    = var.internal_app_port
  to_port                      = var.internal_app_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.dmz.id
}

resource "aws_vpc_security_group_egress_rule" "internal_all_out" {
  security_group_id = aws_security_group.internal.id
  description       = "Sortie autorisee"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
