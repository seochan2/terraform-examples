locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.azs)
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_hostnames = var.enable_dns_hostname

  tags = merge(
    {
      Name = "${var.name}-vpc"
    },
    var.default_tags
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-igw"
    },
    var.default_tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags = merge(
    {
      Name = "${var.name}-subnet-public${count.index + 1}-${var.region}${var.azs[count.index]}"
    },
    var.default_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags = merge(
    {
      Name = "${var.name}-subnet-private${count.index + 1}-${var.region}${var.azs[count.index]}"
    },
    var.default_tags
  )
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name}-eip${count.index + 1}"
    },
    var.default_tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = element(
    aws_eip.nat[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      Name = "${var.name}-nat-public${count.index + 1}-${var.region}${var.azs[count.index]}"
    },
    var.default_tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = merge(
    {
      Name = "${var.name}-rtb-public"
    },
    var.default_tags
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_default_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-rtb-private${count.index + 1}-${var.region}${var.azs[count.index]}"
    },
    var.default_tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count = local.nat_gateway_count

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_default_route_table.default.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags = merge(
    {
      Name = "${var.name}-db-subnet-public${count.index + 1}-${var.region}${var.azs[count.index]}"
    },
    var.default_tags
  )
}

resource "aws_db_subnet_group" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  name        = var.name
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(
    {
      Name = "${var.name}-db-subnet-group"
    },
    var.default_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-rtb-database"
    },
    var.default_tags
  )
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}
