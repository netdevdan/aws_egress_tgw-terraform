variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(any)
}

variable "cidr_block" {
  type = map(any)
}

variable "instance_type" {
  type = string
}

variable "tgw_asn" {
  type = string
}

variable "sg_cidr" {
  type = list(any)
}

variable "ami" {
  type = string
}
