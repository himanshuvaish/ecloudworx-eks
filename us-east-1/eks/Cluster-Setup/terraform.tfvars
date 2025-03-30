region                = "us-east-1"
cluster_name          = "ecloudworx-eks"
cluster_version       = "1.31"
vpc_cidr              = "10.0.0.0/16"
instance_types        = ["t3.medium"]
public-subnet-1-cidr  = "10.0.1.0/24"
public-subnet-2-cidr  = "10.0.2.0/24"
private-subnet-1-cidr = "10.0.101.0/24"
private-subnet-2-cidr = "10.0.102.0/24"
accountid             = "180606272272" # Provide your AWS Account ID
bastion_instance_type = "t2.medium"