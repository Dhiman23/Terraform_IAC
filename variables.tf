variable "cidr" {
  default = "10.0.0.0/16"
  type = string
}

variable "ports" {
  default = ["80", "22"]
  type = list(string)
}

variable "db_password" {
  default =   "admin123"
  type = string
}