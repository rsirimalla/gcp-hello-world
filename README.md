### What is it?
Hello World web application on GCP platform

### Design Considerations
* Simple and scalable
* Stateless
* Standard packaging and deploy
* Simple Monitoring

### Implementation details 
* "Cloud Run" is used as compute service. Why?
    * Its simple & scalable
    * Standard package and deploy - Docker
    * stateless
    * consurrency request handling
    * Perfect spot between cloud functions and GKE
    * Offers custom domain mapping
* "Cloud Spanner" is used ad database solution. Why?
    * Horizantally scalable
    * Managed platform

* "Cloud Build" is used to build CI/CD platform. Why?
    * Scalable
    * Native integration with Cloud Run, IAM, Monitoring

* "terraform" is used for provisioning. Why?
    * Widely adopted
    * Good community support
    * Reusable modules for almost anything

### Code organzation
* `provision` - folder contains code required to provision infrastructure
* `app` - folder contains application code
* `requirements.txt` - Python dependencies
* `Dockerfile` - Package application
* `cloudbuild.yaml` - Steps to perfom on build machine

### How to provision?
* Pre-reqs
    * `gcloud` cli
    * `terraform` 
    * `Docker`
    * `git`

* Steps to provision
    * Clone repository
    * Update project in `provision/terraform.tfvars` 
    * provision
    ```
    git checkout git@github.com:rsirimalla/gcp-hello-world.git
    cd gcp-hello-world/provision
    terraform init
    terraform plan
    terraform apply
    ```
* Make a not of output urls for cloud repo and cloud run service

### How to setup CI/CD pipeline?
* Add GIT remote and push
```
$ git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
$ git remote add google https://source.developers.google.com/p/[PROJECT_ID]/r/[REPO_NAME]
$ git push google master
```

### How to view application
* Open the below URL from browser
```
$ terraform output service_url
```


### Clean up
```
terraform destroy 
```

### Monitoring
* Monitroing keeps getting simple as you go from "you manage"(VMs) => "Managed" => "Serverless"
    * "Cloud Run" default dashboard should help you with most the metrics you looking for
    * Proactive
* Set up alerts based on the pattern in logs
    * Reactive

### Custom domain
* Coudn't perform domain mapping in a automated fashion since it required manual verification


### Enhancements
* Authentication
* Application firewall

### References
https://robmorgan.id.au/posts/deploy-a-serverless-cicd-pipeline-on-gcp-using-cloud-run-and-terraform/  
https://cloud.google.com/blog/topics/developers-practitioners/provisioning-cloud-spanner-using-terraform  
https://github.com/vinycoolguy2015/awslambda/tree/master/gcp_cloudrun_apigateway  
https://github.com/GoogleCloudPlatform/community/tree/master/tutorials/serverless-grafana-with-iap  
https://threedots.tech/post/complete-setup-of-serverless-application/  

