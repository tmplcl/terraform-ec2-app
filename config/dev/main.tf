provider "aws" {
  allowed_account_ids = [343998962661]
}

module "app" {
  source        = "../../modules/app"
  hosted_zone   = "dev-2.coel.link"
  instance_type = "t4g.nano"
  subdomain     = "app2"
  app_name      = "app2"
  vpc_id        = "vpc-0d4ffa9217b89c666"
  environment   = "dev"
  region        = "eu-central-1"
}
