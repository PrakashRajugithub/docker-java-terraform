variable "pub_cidr" {
  default = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  type    = list(any)
}

variable "pvt_cidr" {
  default = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
  type    = list(any)
}