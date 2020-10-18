# jokesapi

# eks cluster creation
1. ecs-cli configure --cluster jokes-gev --default-launch-type FARGATE --config-name jokes-gev-config --region eu-central-1
2. Profile or ecs-cli configure profile --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --profile-name gevorg-api-profile
3. ecs-cli up --cluster-config jokes-gev-config --ecs-profile gevorg-api-profile
4. get SG: aws ec2 describe-security-groups --filters Name=vpc-id,Values= --region=eu-central-1
5. create compose file: ecs-cli compose --project-name gev-project service up --create-log-groups --cluster-config jokes-gev-config --ecs-profile gevorg-api-profile
ecs-cli compose --project-name gev-project service ps --cluster-config jokes-gev-config --ecs-profile gevorg-api-profile