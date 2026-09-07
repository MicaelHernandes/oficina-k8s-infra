output "certificate_arn" {
  description = "ARN do certificado ACM validado."
  value       = aws_acm_certificate_validation.this.certificate_arn
}
