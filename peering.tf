
# 1.Creating the Peering for two Different VPCs
resource "aws_vpc_peering_connection" "default" {
  count       = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id      #requester
  peer_vpc_id = local.default_vpc_id #acceptor
  auto_accept = true

  tags = merge(
    var.common_tags,
    var.vpc_peering_tags,
    {
      Name = "${local.resource_name}-default"
    }
  )

}
#2.Creating the Peering fot public Subnet Route Table

resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = local.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

#3. Creating the Peering for Private Subnet Route Table
resource "aws_route" "private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = local.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# 4.Creating the Peering for database Subnet Route Table
resource "aws_route" "database_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = local.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

#5. Creating the peering for default VPC Route Table

resource "aws_route" "default_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}