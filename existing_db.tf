data "ns_connection" "postgres" {
  name     = "postgres"
  contract = "datastore/aws/postgres:*"
}
