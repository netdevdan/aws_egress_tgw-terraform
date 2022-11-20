output "vpc_id_prod" {
  description = "The ID of the VPC Prod"
  value       = aws_vpc.prod.id
}

output "vpc_id_onprem" {
  description = "The ID of the VPC Prod"
  value       = aws_vpc.onprem.id
}

output "vpc_id_egress" {
  description = "The ID of the VPC Prod"
  value       = aws_vpc.egress.id
}

output "vpc_id_test" {
  description = "The ID of the VPC Prod"
  value       = aws_vpc.test.id
}

output "prod_sub" {
  description = "The ID of the VPC Prod"
  value       = aws_subnet.priv_sub_prod[0].id
}

output "test_sub" {
  description = "The ID of the VPC Prod"
  value       = aws_subnet.priv_sub_test[0].id
}

output "onprem_sub" {
  description = "The ID of the VPC Prod"
  value       = aws_subnet.pub_sub_onprem[0].id
}