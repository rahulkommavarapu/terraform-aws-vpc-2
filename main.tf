
# 1.Create the Vpc
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = var.enable_dns_hostnames
    instance_tenancy = "default"

 # expense-dev
   tags = merge (
    var.common_tags,
    {
        Name = local.resource_name # we put this in Local
    }
   )   
}

# 2.create the Internet Gateway Plugins:-
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge (
        var.common_tags,
        var.igw_tags,
        {
            name = local.resource_name
        }
    )
}
# 3.create the Public Subnet  i want create the  two subnets for this Project
 resource "aws_subnet" "public" {
   
   count  = length(var.public_subnet_cidrs)
   vpc_id = aws_vpc.main.id
   cidr_block = var.public_subnet_cidrs[count.index]
   availability_zone = local.az_names[count.index]
   map_public_ip_on_launch = true #for given the Public Ips for Launch the instances

   tags = merge(
    var.common_tags,
    var.public_subnet_tags,
        {
          Name = "${local.resource_name}-public-${local.az_names[count.index]}"
  
      }
   )
  }
# 4.Create the  Private Subnet 
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = false # for Private Subnet it Look like False in terraform

    tags  = merge (
        var.common_tags,
        var.private_subnet_tags,
        {
            Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        }
    )

}



# 5.Create the Databese Subnet
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = false

    tags = merge (
        var.common_tags,
        var.database_subnet_tags,
        {
            Name = "${local.resource_name}-database-${local.az_names[count.index]}"
        }
    )
}



# 6.Creation of Natgateway and Elastic Ip
resource "aws_eip" "nat" {
    domain = "vpc"

   
          tags =  { 
             Name = "${local.resource_name}-eip"
          }    
    
}
 resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {
        Name = local.resource_name
    }
  )
  

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}


# 7.1 Creating the Route Table for Public,Private,Database -Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.public_route_table_tags,

               {
                Name = "${local.resource_name}-public"
               }
  )
}

# 7.2. Creating the Route Table for Private-Subnet
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = merge (
        var.common_tags,
        var.private_route_table_tags,
        {
            Name = "${local.resource_name}-private"
        }
    )
}

# 7.3. Creating the Route Table for Datbase-Subnet
resource "aws_route_table" "database"{
    vpc_id = aws_vpc.main.id

    tags = merge (
        var.common_tags,
        var.database_route_table_tags,
        {
            Name = "${local.resource_name}-database"
        }
    )
} 

# 8.1.Creating Routes for public subnet route table
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
    destination_cidr_block= "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
}
#8.2 Creating Route for Private Subnet Route_table
resource "aws_route" "private"{
    route_table_id = aws_route_table.private.id
    destination_cidr_block= "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
}

# 8.3 Creating Route For database Subnet Route_table
resource "aws_route" "database"{
    route_table_id = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id 
}
# 9.1 Create Route Table Association for Public subnet
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
   route_table_id = aws_route_table.public.id
}

#9.2 Create Route Table Association for Private Subnet
resource "aws_route_table_association" "private"{
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

#9.3 Create Route Table Association for Database Subnet
   resource "aws_route_table_association" "database"{
    count = length(var.database_subnet_cidrs)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
   }