#=====================VPC=======================

resource "aws_vpc" "prod" {
  cidr_block = var.cidr_block.prod

  tags = {
    "Name" = "prod_vpc"
  }
}

resource "aws_vpc" "test" {
  cidr_block = var.cidr_block.test

  tags = {
    "Name" = "test_vpc"
  }
}

resource "aws_vpc" "onprem" {
  cidr_block = var.cidr_block.onprem

  tags = {
    "Name" = "onprem_vpc"
  }
}

resource "aws_vpc" "egress" {
  cidr_block = var.cidr_block.egress

  tags = {
    "Name" = "egress_vpc"
  }
}

#=====================IGW=======================

resource "aws_internet_gateway" "igw" {
  count  = 2
  vpc_id = [aws_vpc.onprem.id, aws_vpc.egress.id][count.index]

  tags = {
    Name = ["onprem_igw", "egress_igw"][count.index]
  }

}

#=====================Subnets=======================

resource "aws_subnet" "priv_sub_prod" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.prod.id
  cidr_block = cidrsubnet(var.cidr_block.prod, 8, count.index)

  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "Priv_sub_prod: AZ-${["a", "b"][count.index]}"
  }
}

resource "aws_subnet" "priv_sub_test" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.test.id
  cidr_block = cidrsubnet(var.cidr_block.test, 8, count.index)

  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "Priv_sub_test: AZ-${["a", "b"][count.index]}"
  }
}

resource "aws_subnet" "priv_sub_egress" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.egress.id
  cidr_block = cidrsubnet(var.cidr_block.egress, 8, count.index)

  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "Priv_sub_egress: AZ-${["a", "b"][count.index]}"
  }
}

resource "aws_subnet" "pub_sub_egress" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.egress.id
  cidr_block = cidrsubnet(var.cidr_block.egress, 8, count.index + 2)

  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "Pub_sub_egress: AZ-${["a", "b"][count.index]}"
  }
}
resource "aws_subnet" "priv_sub_onprem" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.onprem.id
  cidr_block = cidrsubnet(var.cidr_block.onprem, 2, count.index)

  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "Priv_sub_onprem: AZ-${["a", "b"][count.index]}"
  }
}

resource "aws_subnet" "pub_sub_onprem" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.onprem.id
  cidr_block = cidrsubnet(var.cidr_block.onprem, 2, count.index + 2)

  availability_zone = element(var.availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "Pub_sub_onprem: AZ-${["a", "b"][count.index]}"
  }
}
#=====================VPC-RTBs===================

resource "aws_route_table" "vpc_route_table" {
  count = 2
  vpc_id = [aws_vpc.test.id, aws_vpc.prod.id][count.index]

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  }
  tags = {
    "Name" = ["test-vpc-rtb", "proc_vpc_rtb"][count.index]
  }
}

resource "aws_route_table_association" "vpc_rtb_ass_prod" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.priv_sub_prod.*.id, count.index)
  route_table_id = aws_route_table.vpc_route_table[1].id
}

resource "aws_route_table_association" "vpc_rtb_ass_test" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.priv_sub_test.*.id, count.index)
  route_table_id = aws_route_table.vpc_route_table[0].id
}

resource "aws_route_table" "onprem_rtb_pub" {
  vpc_id = aws_vpc.onprem.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  }

  tags = {
    "Name" = "onprem-vpc-rtb"
  } 
}

resource "aws_route_table_association" "onprem_rtb_ass_pub" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.pub_sub_onprem.*.id, count.index)
  route_table_id = aws_route_table.onprem_rtb_pub.id
}

resource "aws_route_table" "egress_rtb_pub" {
  vpc_id = aws_vpc.egress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[1].id
  }
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  }

  tags = {
    "Name" = "egress-vpc-rtb"
  } 
}

resource "aws_route_table_association" "egress_rtb_ass_pub" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.pub_sub_egress.*.id, count.index)
  route_table_id = aws_route_table.egress_rtb_pub.id
}

resource "aws_route_table" "egress_rtb_priv_A" {
  vpc_id = aws_vpc.egress.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.egress-nat[0].id
  }

  tags = {
    "Name" = "egress-vpc-rtb-priv-A"
  } 
}

resource "aws_route_table" "egress_rtb_priv_B" {
  vpc_id = aws_vpc.egress.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.egress-nat[1].id
  }

  tags = {
    "Name" = "egress-vpc-rtb-priv-B"
  } 
}

resource "aws_route_table_association" "egress_rtb_ass_priv_A" {
  subnet_id = aws_subnet.priv_sub_egress.0.id
  route_table_id = aws_route_table.egress_rtb_priv_A.id
}

resource "aws_route_table_association" "egress_rtb_ass_priv_B" {
  subnet_id = aws_subnet.priv_sub_egress.1.id
  route_table_id = aws_route_table.egress_rtb_priv_B.id
}

#=====================NATGW=======================

resource "aws_eip" "nat_1" {
  vpc = true
}

resource "aws_eip" "nat_2" {
  vpc = true
}

resource "aws_nat_gateway" "egress-nat" {
  count = length(var.availability_zones)
  allocation_id = [aws_eip.nat_1.id, aws_eip.nat_2.id][count.index]
  subnet_id = element(aws_subnet.pub_sub_egress.*.id, count.index)

  tags = {
    "Name" = "Egress NATGW"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

#=====================TGW=======================

resource "aws_ec2_transit_gateway" "TGW-Main" {
  description = "Main TGW"
  amazon_side_asn = var.tgw_asn
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod-att" {
  subnet_ids = aws_subnet.priv_sub_prod[*].id
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  vpc_id = aws_vpc.prod.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    "Name" = "prod_vpc_att"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "test-att" {
  subnet_ids = aws_subnet.priv_sub_test[*].id
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  vpc_id = aws_vpc.test.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    "Name" = "test_vpc_att"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "onprem-att" {
  subnet_ids = aws_subnet.priv_sub_onprem[*].id
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  vpc_id = aws_vpc.onprem.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    "Name" = "onprem_vpc_att"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress-att" {
  subnet_ids = aws_subnet.priv_sub_egress[*].id
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id
  vpc_id = aws_vpc.egress.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  appliance_mode_support = "enable"

  tags = {
    "Name" = "egress_vpc_att"
  }
}

resource "aws_ec2_transit_gateway_route_table" "vpc-tgw-rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id

  tags = {
    "Name" = "rtb-vpc"
  }
}

resource "aws_ec2_transit_gateway_route_table" "onprem-tgw-rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id

  tags = {
    "Name" = "rtb-onprem"
  }
}

resource "aws_ec2_transit_gateway_route_table" "egress-to-vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW-Main.id

  tags = {
    "Name" = "rtb-egress-to-vpc"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "onprem-tgw-ass" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.onprem-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem-tgw-rtb.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc-tgw-ass" {
  count = 2
  transit_gateway_attachment_id = [aws_ec2_transit_gateway_vpc_attachment.prod-att.id, aws_ec2_transit_gateway_vpc_attachment.test-att.id][count.index]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc-tgw-rtb.id
}

resource "aws_ec2_transit_gateway_route_table_association" "egress-to-vpc-tgw-ass" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.egress-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress-to-vpc.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_routes" {
  count = 2
  transit_gateway_attachment_id = [aws_ec2_transit_gateway_vpc_attachment.prod-att.id, aws_ec2_transit_gateway_vpc_attachment.test-att.id][count.index]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.onprem-tgw-rtb.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "onprem_egress_routes" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.onprem-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc-tgw-rtb.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "egress-to-vpc" {
  count = 2
  transit_gateway_attachment_id = [aws_ec2_transit_gateway_vpc_attachment.prod-att.id, aws_ec2_transit_gateway_vpc_attachment.test-att.id][count.index]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress-to-vpc.id
}

resource "aws_ec2_transit_gateway_route" "egress_nat_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.egress-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc-tgw-rtb.id
}

resource "aws_ec2_transit_gateway_route" "block_vpc_comms" {
  destination_cidr_block = "10.0.0.0/8"
  blackhole = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc-tgw-rtb.id
}