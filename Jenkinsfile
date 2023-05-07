pipeline {
    agent any

    environment {
        PATH = "${PATH}:${getTerraformPath()}"
        AWS_DEFAULT_REGION='us-east-1'
        AWS_CREDENTIALS= credentials('aws-auth')
    }

    stages{

        stage('Create S3 Bucket'){
            steps{
                script{
                    createS3Bucket('joe-terraform-2023-05-05')
                }
            }
        }

        stage('Create DynamoDB'){
            steps{
                script{
                    createDynamoDB('onyxquity-fargate-terraform-lock')
                }
            }
        }

        stage('Create ECR_REPO'){
            steps{
                script{
                    createECR('fargate-cicd-pipeline')
                }
            }
        }

        stage('Dev - init and apply'){
            steps{
                dir('terraform/ecr_registry') {
                    sh "pwd"
                    sh returnStatus: true, script: 'terraform workspace new dev'
                    sh "terraform init -upgrade"
                    sh "terraform apply -auto-approve -var-file=dev.tfvars"
                    script{
                        registry_id = sh(returnStdout: true, script: "terraform output registry_id").trim()
                        repository_name = sh(returnStdout: true, script: "terraform output repository_name").trim()
                        repository_url = sh(returnStdout: true, script: "terraform output repository_url").trim()
                    }
                }
            }
        }

        stage("AWS ECR Athentication"){
            steps{
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${registry_id}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
            }
        }

        stage("Deploy Image to AWS ECR"){
            steps{
                sh "docker image build -t ${repository_name}:${BUILD_ID} ."
                sh "docker tag ${repository_name}:${BUILD_ID} ${repository_url}:${BUILD_ID}"
                sh "docker push ${repository_url}:${BUILD_ID}"
            }
        }

    }
}


def getTerraformPath(){
    def tfHome = tool name: 'terraform:1.4.6', type: 'terraform'
    return tfHome
}


def createS3Bucket(bucketName){
    sh returnStatus: true, script: "aws s3 mb s3://${bucketName} --region=us-east-1"
}

def createECR(repoName){
    sh returnStatus: true, script: "aws ecr create-repository --repository-name ${repoName} --image-scanning-configuration scanOnPush=true --region ${AWS_DEFAULT_REGION}"
}


def createDynamoDB(dynamodbName){
    sh returnStatus: true, script: "aws dynamodb create-table --table-name ${dynamodbName} --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5"
}

def registry_id

def repository_name

def repository_url

// ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)

// aws ecr create-repository --respository-name <repo_name> --region <region_name>