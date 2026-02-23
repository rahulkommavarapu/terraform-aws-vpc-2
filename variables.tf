variable "project_name"{

}

variable "environment"{

}

variable "vpc_cidr" {

}

variable "enable_dns_hostnames" {
    default = true
}
# we will optional or mandatory
variable "common_tags" {
   type = map (string)
   
   default = {}
}

variable "vpc_tags" {
  type = map(string)
}

variable "igw_tags"{
    default = { }

}
 
variable "public_subnet_cidrs"{
    type = list
    validation {
        condition = length(var.public_subnet_cidrs) == 2
        error_message = "please provide 2 valid public subnet CIDR"
    }
}

variable "public_subnet_tags"{
    default = {}
}

variable "private_subnet_cidrs"{
    type = list
    validation {
        condition = length(var.private_subnet_cidrs) == 2
        error_message = "Please Provide 2 valid priavate subnet CiDR"
    }
}
 variable "private_subnet_tags"{
    default = {}
 }

variable "database_subnet_cidrs" {
    type = list
    validation {
        condition = length(var.database_subnet_cidrs) == 2
        error_message = "Please Provide 2 valid private subnet CIDR"
    }
}

variable "database_subnet_tags"{
    default = {}
}
variable "nat_gateway_tags" {
    default = {}
}
variable "public_route_table_tags" {
    default = {}
}
variable "private_route_table_tags"{
    default = {}
}
variable "database_route_table_tags" {
  default = {}
}

 variable "is_peering_required"{
    type = bool
    default = false
 }



variable "vpc_peering_tags" { 
  default     = {}
}
