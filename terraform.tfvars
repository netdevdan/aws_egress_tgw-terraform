availability_zones = ["eu-west-2a", "eu-west-2b"]
cidr_block         = { egress = "10.10.0.0/16", prod = "10.40.0.0/16", test = "10.50.0.0/16", onprem = "192.168.100.0/24" }

key_name      = "TGW-test"
instance_type = "t3.micro"

tgw_asn = "65150"

sg_cidr = ["0.0.0.0/0"]

ami = "ami-04706e771f950937f"