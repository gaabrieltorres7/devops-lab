module "k8s" {
  source = "github.com/gaabrieltorres7/terraform-aws?ref=main"

  project_name = "devops-lab"
  region       = "us-east-1"
  cidr_block   = "10.34.0.0/16"
  tags = {
    Environment = "dev"
    Owner       = "gaabrieltorres7"
    Department  = "DevOps"
  }
}
