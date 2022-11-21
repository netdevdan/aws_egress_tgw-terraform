output "sg_id_prod" {
  description = "The ID of the sg Prod"
  value       = [aws_security_group.allow_all_prod.id]
}

output "sg_id_onprem" {
  description = "The ID of the sg OnPrem"
  value       = [aws_security_group.allow_all_onprem.id]
}

output "sg_id_egress" {
  description = "The ID of the sg egress"
  value       = [aws_security_group.allow_all_egress.id]
}

output "sg_id_test" {
  description = "The ID of the sg test"
  value       = [aws_security_group.allow_all_test.id]
}