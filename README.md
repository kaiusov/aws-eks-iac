# aws-eks-iac

pre-requisites 
- configure AWS CLI login
 - create an AWS account
 - configure MFA for the root account and never use it unless it's an emergency
 - create a user with sufficient access to creating resources (vpc, eks, etc) or stick with Admin access for simplicity
 - configure MFA for the new user and generate a password to sign in (optional - if access to web UI is required)
 - generate Access Keys
 - install AWS CLI
 - configure Access and Secret key
- install terraform and terragrunt
- delete default VPC and underlying resources (optional - default VPC will not be used and can be deleted)
- go through aws-eks-iac/tg/prod/env.hcl and aws-eks-iac/tg/prod/account.hcl - at least account and iam user name has to be changed, other settings are optional.


cd aws-eks-iac/tg/prod/ - change directory to root module of prod env terragrunt configuration
terragrun init - 
terragrunt run-all apply --auto-approve - run terragrunt to deploy vpc module, eks module (and login to eks kube), metrics server eks-module and nginx-server eks module


## for simplicity everything is deployed in default namespace

kubectl get pods - ensure that pods are in running state 
kubectl get svc - copy the LB dns name - this will be the url to check the nginx through public internet. Either copy-paste it to browser or run curl

curl -I k8s-default-nginxser-4ccabacc7d-850683e3840ed893.elb.us-east-1.amazonaws.com

HTTP/1.1 200 OK
Server: nginx
Date: Thu, 06 Mar 2025 12:22:22 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 10 Jan 2024 03:29:36 GMT
Connection: keep-alive
ETag: "659e0f20-267"
X-Frame-Options: SAMEORIGIN
Accept-Ranges: bytes

this response would mean that nginx is reachable and serves the example web-page
IMPORTANT - DNS record for the LB might take up to 15 mins to propagate in order for the web page to be accessible


kubectl get hpa - check that the hpa has metrics and replicas are set to 1
kubectl get nodes - check the number of nodes to later compare and make sure that node scaling is working
kubectl run load-generator --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://nginx-server; done" - deploy a load generator pod to test pod autoscaling

kubectl get hpa - ensure that cpu is > than 80% and replicas are scaling (might take a minute or two). Newly created replicas show that HPA is working.
kubectl get nodes - as the the pods don't conmsume a lot of resources the node number might still be just 1
kubectl scale deployment nginx-server --replicas=50 - scale up the deployment manually to test node auto-scaling
kubectl get nodes - newly created nodes show that cluster auto-scaling is working
kubectl delete pod load-generator - delete the load testing pod 
kubectl get hpa - as there is no load anymore and cpu consumed is way less than the threshold gradually the hpa will scale down the replicas to 1
kubectl get nodes - nodes will automatically scale down to 1 too over time


After pod and node autoscaling confirmed to be working delete the whole infrastructure with terragrunt destroy --auto-approve


851725482350
jA^%A7|'

# cluster oidc? in eks
# least privilege for user iam access
# parametrize values in the eks-modules' template files
# improve observability - install ELK and Prometheus+Grafana for proper logs and metrics monitoring
# tweak the resource requests and limits after observing average/peak lod in pod
# change instance type to a more cost-efficient one  
# uncomment the plugins in the EKS cluster
# create dns records and generate ssl certificates (I would use cloudflare to also provide enhanced security, performance, and reliability - DDoS Protection, WAF, Rate Limiting etc )
# deploy ingress controller to properly manage external access to services
# disaster recovery plan and backups
# deploy coredns and kube-proxy addons to the cluster for dns resolution and networking in the cluster
# create separate namespaces for different modules after up
# create a docker file for the intended web-server, create a repository, set up CI/CD etc/ ALTERNATIVELY - if the web-page is just static - then tear the whole infrastructure down and use s3 for hosting with DNS and ssl set up or use any similar simple solution


## gitignore file to not commit cache files