
output "aws_db_instance_transactional_database" {
  description = "Transactional RDS Database Database Name"
  value       = local.transactional_database
}

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

output "aws_security_group_dms_sg" {
  description = "AWS Security Group DMS"
  value       = aws_security_group.dms_sg.id
}
