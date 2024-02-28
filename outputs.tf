output "db_ip" {
  value = module.myapp-sqldb.mysql_server_fqdn
}
  