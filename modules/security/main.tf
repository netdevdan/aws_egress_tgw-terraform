resource "aws_security_group" "allow_all_prod" {
    name = "allow all"
    description = "allow all traffic for testing/ lab"
    vpc_id = var.vpc_id_prod

    ingress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    egress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    tags = {
        "Name" = "allow_all"
    }
}

resource "aws_security_group" "allow_all_test" {
    name = "allow all"
    description = "allow all traffic for testing/ lab"
    vpc_id = var.vpc_id_test

    ingress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    egress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    tags = {
        "Name" = "allow_all"
    }
}

resource "aws_security_group" "allow_all_onprem" {
    name = "allow all"
    description = "allow all traffic for testing/ lab"
    vpc_id = var.vpc_id_onprem

    ingress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    egress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    tags = {
        "Name" = "allow_all"
    }
}

resource "aws_security_group" "allow_all_egress" {
    name = "allow all"
    description = "allow all traffic for testing/ lab"
    vpc_id = var.vpc_id_egress

    ingress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    egress {
        description = "all traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = var.sg_cidr
    }

    tags = {
        "Name" = "allow_all"
    }
}