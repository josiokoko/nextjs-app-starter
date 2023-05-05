pipeline {
    agent any

    environment {
        PATH = "${PATH}:${getTerraformPath()}"
        AWS_ACCESS_KEY_ID = credentials('my-predefined-aws-acess-key-id-text') 
        AWS_SECRET_ACCESS_KEY = credentials('my-predefined-aws-secret-key-text')
    }

    stages{

        stage('Create s3 Bucket and DynamoDB'){
            steps{
                script{
                    createS3Bucket('joe-terraform-09-09')
                    createDynamoDB('onyxquity-fargate-terraform-lock')
                }
            }
        }

        stage('Dev - init and apply'){
            steps{
                sh "cd terraform/ecr_registry/"
                sh returnStatus: true, script: 'terraform workspace new dev'
                sh "terraform init"
                sh "terraform apply -auto-approve -var-file=dev.tfvars"

                registry_id = sh(returnStdout: true, script: "terraform output registry_id").trim()
                repository_name = sh(returnStdout: true, script: "terraform output repository_name").trim()
                repository_url = sh(returnStdout: true, script: "terraform output repository_url").trim()
            }
        }

        stage("AWS ECR Athentication"){
            steps{
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${registry_id}.dkr.ecr.${AWS_REGION}.amazonaws.com"
            }
        }

        stage("Deploy Image to AWS ECR"){
            steps{
                sh "docker image build -t ${repository_name}:${BUILD_ID} ."
                sh "docker tag ${repository_name}:${BUILD_ID} ${repository_url}:${BUILD_ID}"
                sh "docker push ${repository_url}:${BUILD_ID}"
            }
        }

        stage('Dev - destroy'){
            steps{
                sh returnStatus: true, script: 'terraform workspace new dev'
                sh "terraform destroy -auto-approve"
            }
        }

    }
}


def getTerraformPath(){
    def tfHome = tool name: 'terraform:1.4.6', type: 'terraform'
    return tfHome
}


def createS3Bucket(bucketName){
    sh returnStatus: true, script: "aws s3 mb ${bucketName} --region=us-east-1"
}


def createDynamoDB(dynamodbName){
    sh returnStatus: true, script: "aws dynamodb create-table --table-name ${dynamodbName} --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5"
}

def registry_id

def repository_name

def repository_url

// ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)