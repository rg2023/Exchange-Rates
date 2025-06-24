# variable "region" {
#   type    = string
# }
# variable "project_id" {
#   type    = string
# }
# variable "sa_email_to_impersonate" {
#   type = string 
# }


variable "region" {
  type    = string
}
variable "project_id" {
  type    = string
}
variable "sa_email_to_impersonate" {
  type = string 
}
variable "db_instance" {
  type    = string
  default = "db"
}
variable "db_name"{
  type    = string
  default = "database"
}