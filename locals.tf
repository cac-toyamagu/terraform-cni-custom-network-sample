locals {
  cluster_name = "toyamagu-eks-cluster"
  region       = "ap-northeast-1"
}

locals {
  vpc = {
    azs             = ["${local.region}a", "${local.region}c", "${local.region}d"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    intra_subnets   = ["100.64.1.0/24", "100.64.2.0/24", "100.64.3.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
}
