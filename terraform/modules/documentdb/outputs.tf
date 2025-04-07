// modules/documentdb/outputs.tf
output "cluster_id" {
  description = "ID of the DocumentDB cluster"
  value       = aws_docdb_cluster.default.id
}

output "cluster_resource_id" {
  description = "Resource ID of the DocumentDB cluster"
  value       = aws_docdb_cluster.default.cluster_resource_id
}

output "cluster_endpoint" {
  description = "Endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.default.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.default.reader_endpoint
}

output "port" {
  description = "Port of the DocumentDB cluster"
  value       = aws_docdb_cluster.default.port
}