
output "aws_lambda_enrich_arn" {
  description = "Arn of enrich lambda"
  value       = aws_lambda_function.enrich_data.arn
}
