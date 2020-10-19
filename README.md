  

# Introduction

This repository contains code that is responsible for deploying simple flask application in ECS. Deployment starts with provisioning an AWS infrastructure (EC2), running Ansible to install the required packages and dependencies. Starting a ConcourseCI to build and push Dockerimage containing the flask app to Amazon ECR repository and then updating the ECS service with a new image. 


# Deployment

1. Customize variables and run terraform code in `/infra` folder. Terraform will deploy an EC2 machine, assign elastic IP and create a var file for Ansible.

  The only manual input is required when Ansible ssh's to the EC2 - you will need to confirm the connection by manually typing yes. Totaling to 2 manual inputs - terraform apply   and then confirm known_hosts for SSH. 
  Remember to specify `cidr_blocks = [""]` in network.tf as it will define which IP addresses can connect to the EC2 (ConcourseCI server) .
  Remember to provide valid public and private key paths.
  For running Ansible and generating var file I have used # [cloudposse](https://github.com/cloudposse)/**[terraform-null-ansible](https://github.com/cloudposse/terraform-null-   ansible)** module. It has been cloned into the repo as a module and updated to work with terraform v13. It can be updated further since it still shows some depreciation    
  warnings.
  Mind the `var_files` in `master.yml` as it specifies where to find the variables for Ansible (created by `resource "local_file" "tf_ansible_vars_file_new"`)

2. After terraform apply we will have a running Concourse CI instance on EC2 and Ansible will trigger to install docker, docker compose and run the Concourse CI.

Please mind that Concourse containers are specified to bind to - "/var/run/docker.sock:/var/run/docker.sock" so they can be acessible from the EC2 host IP.

  

Log into the Concourse CI under the **EC2_public_IP:8080**

  

`fly --target=$target login --concourse-url=$concourse-url --team-name=main`

  

`fly -t $target set-pipeline -c pipeline.yml -p $pipeline`

  

Unpause the pipeline and you are ready to go.

  

In case of using the credentials file do not push it into the repository and instead supply the file to Concourse by adding `-l` flag to fly cli when creating and updating the `app-pipeline.yml`:

  

`fly -t ppe set-pipeline -c ci/app-pipeline.yml -p testing-hello -l ci/credentials.yml`

  

On the contents of credentials file look at point `5.`

  

3. Each time the github repository specified in app-pipeline.yml get's a commit the pipeline will trigger to build a new image, push and start new service deployment in ECS - resulting in new IP address that will host the flask app.

To achieve a dev environemnt you can also add jobs and divide them into a pull-request and master branch jobs groups. In that case a developer would trigger a new run based on a created new pull-request and only after merging the feature branch into the master would it result in replacing the "production" environment.  

4. To redeploy the ECS entirely you can edit the code in the `run-api.yml` and follow AWS ECS [official documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html) otherwise the current code redeploys a new service and then sleeps for 120s waiting till new service replaces the old one.

  

5. Do not forget to specify a credentials.yml file in CI directory. At the moment it serves as a credentials source.

```

aws-token: AWS_ACCESS_KEY_ID

aws-secret: AWS_SECRET_ACCESS_KEY

aws-repo: ECR-uri

github-username: Username

github-access-token: Token

```

**Note:** Please note that this is a development code and you should be using external credentials manager like Vault or CredHub - specifying the `var_sources` and referencing the accordingly after the credentials manager is up. More [information](https://concourse-ci.org/creds.html).

  

7. You can manually check at which address the ECS is serving the app by running:

`ecs-cli compose --project-name $project_name service ps --cluster-config $config --ecs-profile $profile`

8. After navigating to the IP address you will be presented with a landing page of the app.

  

# EKS cluster creation

In case of deploying the whole environment you should follow the mentioned in point 4. ECS official [tutorial](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html). After the ECS is running you can then use the run-api.yml to run new images in ECS.
