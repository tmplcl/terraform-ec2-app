# terraform-ec2-app

Simple showcase on how to deploy a load balanced application with Terraform to EC2 using the following services:

- EC2 / ASG
- ALB
- Docker

## Structure

- This repo uses a common Terraform Module `app` that can be deployed to different environments.
- The module is located under the `modules/app` directory.
- The configurations for each environment are located under the `config/<environment>` directories.

## Deployment

Once you configured the module for an environment like here for example the dev environment you can deploy
this app by running `terraform init` and `terraform apply` under the specific config directory

The output should look something like this:

```
Apply complete! Resources: 0 added, 2 changed, 0 destroyed.

Outputs:

alb = "arn:aws:elasticloadbalancing:eu-central-1:343998962661:loadbalancer/app/tf-lb-20220807091552886900000005/06eabf48b7b76385"
ami = "ami-09d542aa0f9c09c25"
asg = "arn:aws:autoscaling:eu-central-1:343998962661:autoScalingGroup:aeaee229-fa0c-42cf-a9d0-4bd339927aa3:autoScalingGroupName/terraform-20220807091554154500000009"
route = "https://app2.dev-2.coel.link"
```

It might take a few seconds for the application to be available after the deployment. Once it is ready you can
access your application over the url provided by the Terraform output.

```
❯ curl https://app2.dev-2.coel.link
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
