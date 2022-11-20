resource "aws_network_interface" "prod" {
    subnet_id = var.prod_sub
    security_groups = var.sg_id_prod
}

resource "aws_network_interface" "test" {
    subnet_id = var.test_sub
    security_groups = var.sg_id_test
}

resource "aws_network_interface" "onprem" {
    subnet_id = var.onprem_sub
    security_groups = var.sg_id_onprem
}

resource "aws_instance" "prod" {
    ami = var.ami #eu-west-2, amz
    instance_type = var.instance_type

    network_interface {
      network_interface_id = aws_network_interface.prod.id
      device_index = 0
    }

    key_name = var.key_name
}

resource "aws_instance" "test" {
    ami = var.ami #eu-west-2, amz
    instance_type = var.instance_type

    network_interface {
      network_interface_id = aws_network_interface.test.id
      device_index = 0
    }

    key_name = var.key_name
}

resource "aws_instance" "onprem" {
    ami = var.ami #eu-west-2, amz
    instance_type = var.instance_type

    network_interface {
      network_interface_id = aws_network_interface.onprem.id
      device_index = 0
    }

    key_name = var.key_name
}