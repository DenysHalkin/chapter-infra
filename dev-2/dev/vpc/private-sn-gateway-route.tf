resource "aws_route" "private_sn_internet_gateway" {
  count = local.create_private_subnets && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  route_table_id         = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}