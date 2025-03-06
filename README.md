# aws-eks-iac

This is a project for a simple AWS EKS cluster terraform+terragrunt provisioning with Nginx and metrics server with horizontal pod autoscaling and cluster node autoscaling set up.

Directory tree
```bash
├── README.md
├── tf
│   ├── eks
│   │   ├── README.md
│   │   ├── data_sources.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── remote_states.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── eks-modules
│   │   ├── metrics-server
│   │   │   ├── README.md
│   │   │   ├── data_sources.tf
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── remote_states.tf
│   │   │   ├── templates
│   │   │   │   └── metrics-server-values.yaml
│   │   │   ├── variables.tf
│   │   │   └── versions.tf
│   │   └── nginx-server
│   │       ├── README.md
│   │       ├── data_sources.tf
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── remote_states.tf
│   │       ├── templates
│   │       │   └── nginx-server-values.yaml
│   │       ├── variables.tf
│   │       └── versions.tf
│   └── vpc
│       ├── README.md
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── versions.tf
└── tg
    └── prod
        ├── account.hcl
        ├── eks
        │   └── terragrunt.hcl
        ├── eks-modules
        │   ├── metrics-server
        │   │   └── terragrunt.hcl
        │   └── nginx-server
        │       └── terragrunt.hcl
        ├── env.hcl
        ├── terragrunt.hcl
        └── vpc
            └── terragrunt.hcl
```

Terraform modules in tf folder in this setup are made to be reusable and void of environment variables - the variables are supposed to be set up either in the account.hcl/env.hcl of the root module (environment folder e.g. prod) or as overrides in child modules.

This would allow for quick and easy new env stack deploy (e.g dev) with minimal tweaks in terragrunt configuration.

### Pre-requisites 
- **configure AWS access**:
    - create an AWS account
    - configure MFA for the root account and never use it unless it's an emergency
    - create a user with sufficient access to creating resources (vpc, eks, etc) or stick with Admin access for simplicity
    - configure MFA for the new user and generate a password to sign in (optional - if access to web UI is required)
    - generate Access Keys
    - install AWS CLI
    - configure Access and Secret key
- install terraform, terragrunt, kubectl jq (this one is ***optional*** - to delete the state bucket completely. Empty bucket with no requests to it won't be billed)
- delete default VPC and underlying resources (***optional*** - default VPC will not be used and can be deleted)
- go through aws-eks-iac/tg/prod/env.hcl and aws-eks-iac/tg/prod/account.hcl - at least account and iam user name has to be changed, other settings are optional.

### Terragrunt provisioning of resources
```bash
cd aws-eks-iac/tg/prod/
```
change directory to root module of prod env terragrunt configuration (or just aws-eks-iac/tg since we only have 1 env-stack)
```bash
terragrunt run-all apply --auto-approve 
```
run terragrunt to create state bucket and dynomodb lock table deploy vpc, eks cluster (and login your machine to eks kube), metrics server and nginx-server helm releases

--auto-approve and --terragrunt-non-interactive - to skip confirmations regarding stack creation, state bucket + dynamodb creation and apply confirmations of each module. Avoid using on real prod envs.


stack creation should take from 20 to 40 minutes depending on eks cluster creation speed by AWS

***for simplicity everything is deployed in default kubernetes namespace***

### Testing pod and node autoscaling

```bash
kubectl get pods
```
ensure that pods are in running state 
```bash
kubectl get svc
```
copy the LB dns name of nginx-server service, this will be the url to check the nginx through public internet. Either paste it to browser or run curl

```bash
curl -I k8s-default-nginxser-4ccabacc7d-850683e3840ed893.elb.us-east-1.amazonaws.com
```

```bash
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
```

this response would mean that nginx is reachable and serves the example web-page

**IMPORTANT - DNS record for the LB might take up to 15 mins to propagate in order for the web page to be accessible**

```bash
kubectl get hpa 
```
check that the hpa has metrics (confirms that the metrics server is working) and replicas are set to 1
```bash
kubectl get nodes 
```
check the number of nodes to later compare and make sure that node scaling is working
```bash
kubectl run load-generator --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://nginx-server; done" 
```
deploy a load generator pod to test pod autoscaling

```bash
watch 'kubectl get hpa'
```
ensure that cpu is > than 80% and replicas are scaling (might take a minute or two). Newly created replicas show that HPA is working.

```bash
kubectl get nodes
```
as the the pods don't consume a lot of resources the node number might still be just 1, even though a lot of replicas were deployed
```bash
kubectl scale deployment nginx-server --replicas=50
```
scale up the deployment manually to test node auto-scaling
```bash
watch 'kubectl get nodes'
```
newly created nodes show that cluster auto-scaling is working
```bash
kubectl delete pod load-generator
```
delete the load testing pod 
```bash
watch 'kubectl get hpa'
```
as there is no load anymore and cpu consumed is way less than the threshold the hpa will scale down the replicas to 1 over time
```bash
kubectl get nodes
```
gradually nodes will automatically scale down to 1 too


After pod and node autoscaling confirmed to be working delete the whole infrastructure with
```bash
terragrunt run-all destroy --auto-approve --terragrunt-non-interactive
```
clean up the s3 state bucket and dynamodb table
```bash
  aws s3 rm s3://faraway-prod-terraform-state --recursive
  aws dynamodb delete-table --table-name faraway-prod-terraform-locks
  aws s3api delete-bucket --bucket faraway-prod-terraform-state 
  ```

  if there are errors when deleting the bucket then it's due to leftover versioned objects
```bash
  aws s3api list-object-versions --bucket faraway-prod-terraform-state --output json \
    | jq -r '.Versions[] | [.Key, .VersionId] | @tsv' \
    | while read -r key version_id; do
        aws s3api delete-object --bucket faraway-prod-terraform-state --key "$key" --version-id "$version_id"
      done

  aws s3api list-object-versions --bucket faraway-prod-terraform-state --output json \
    | jq -r '.DeleteMarkers[] | [.Key, .VersionId] | @tsv' \
    | while read -r key version_id; do
        aws s3api delete-object --bucket faraway-prod-terraform-state --key "$key" --version-id "$version_id"
      done
  ```

# Production consideration:

## Security 
- least privilege for user iam access
- use OIDC and IRSA for cluster access
- implement RBAC for services and users in cluster
- proper network policies in the cluster

## Networking 
- re-check all the cluster and vpc sercurity rules and make sure that what's private stays private
- deploy coredns and kube-proxy addons to the cluster for dns resolution and networking in the cluster. In my example I disabled those as they were not required/used in the task and it allowed stack creation to take less time. (uncomment the plugins in the EKS cluster)
- create separate namespaces for different modules after enabling addons above for better organization and network policies between namespaces
- create dns records and generate ssl certificates (I would use cloudflare to also provide enhanced security, performance, and reliability - DDoS Protection, WAF, Rate Limiting etc )
- deploy ingress controller to properly manage external access to services

## Observability
- improve observability - install ELK and Prometheus+Grafana for proper logs and metrics monitoring
- set up cloudwatch alarms high cpu/ memory, failed pods or eks-cluster errors

## Cost-Efficiency and optimization
- tweak the resource requests and limits after observing average/peak load in pod
- change instance type to a more cost-efficient one  
- parametrize values in the eks-modules' template files. Current values are hardcoded but they should be parametrized, set as vars and set up in tg module
- create a docker file for the intended web-server, create a repository, set up CI/CD etc. ALTERNATIVELY - if the web-page is just static - then tear the whole infrastructure down and use s3 for hosting with DNS and ssl set up or use any similar simple solution that would be less costly

## Disaster Recovery and Backups
- implement disaster recovery plan and backups according to budget and requirements

# Misc
- Prod can't be prod unless there is a dev environment set up for development and testing. This repo would allow to spin up an identical dev environment with minimum effort.
- I see that terragrunt changed the root terragrunt.hcl to root.hcl. This is something I would later address.
```bash
WARN   [prod/eks] Using `terragrunt.hcl` as the root of Terragrunt configurations is an anti-pattern, and no longer recommended. In a future version of Terragrunt, this will result in an error. You are advised to use a differently named file like `root.hcl` instead. For more information, see https://terragrunt.gruntwork.io/docs/migrate/migrating-from-root-terragrunt-hcl
  ```


