
output "aws_db_instance_transactional_address" {
  description = "Transactional RDS Database Address"
  value       = aws_db_instance.transactional.address
}

output "aws_db_instance_transactional_port" {
  description = "Transactional RDS Database Port"
  value       = aws_db_instance.transactional.port
}

output "aws_db_instance_transactional_root_user" {
  description = "Transactional RDS Database User"
  value       = local.transactional_root_user
}

output "aws_db_instance_transactional_root_password" {
  description = "Transactional RDS Database Password"
  value       = local.transactional_root_password
}
