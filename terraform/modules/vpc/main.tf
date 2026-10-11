# Module VPC — architecture segmentée DMZ (publique) + zone interne (privée)

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

# --- Passerelle Internet (pour la DMZ uniquement) ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

# --- Sous-réseau DMZ (public) ---
resource "aws_subnet" "dmz" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.dmz_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-dmz"
    Zone    = "dmz"
    Project = var.project
  }
}

# --- Sous-réseau interne (privé) ---
resource "aws_subnet" "internal" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.internal_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-internal"
    Zone    = "internal"
    Project = var.project
  }
}

# --- Table de routage publique (DMZ -> IGW) ---
resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name    = "${var.project}-rt-dmz"
    Project = var.project
  }
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = aws_subnet.dmz.id
  route_table_id = aws_route_table.dmz.id
}

# --- Table de routage interne (aucune route Internet par défaut) ---
# Pas de NAT Gateway : il n'est PAS couvert par le Free Tier.
# La zone interne reste isolée d'Internet ; elle n'est joignable que depuis la DMZ.
resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name    = "${var.project}-rt-internal"
    Project = var.project
  }
}

resource "aws_route_table_association" "internal" {
  subnet_id      = aws_subnet.internal.id
  route_table_id = aws_route_table.internal.id
}
