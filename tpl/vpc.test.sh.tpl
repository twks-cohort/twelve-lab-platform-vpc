#!/usr/bin/env bash
ENVIRONMENT=$1

case ENVIRONMENT in

  sandbox)
    AWS_ACCOUNT={{ twdps/di/svc/aws/dps-2/aws-account-id }}
    ;;

  preview)
    AWS_ACCOUNT={{ twdps/di/svc/aws/dps-2/aws-account-id }}
    ;;

  *)
    echo 'there is no account mapping for the specified environment: ${1}'
    exit 1
    ;;
esac

aws sts assume-role --output json --role-arn arn:aws:iam::${ENVIRONMENT}:role/DPSTerraformRole --role-session-name awspec-test > credentials

export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")
export AWS_DEFAULT_REGION=$(cat $1.auto.tfvars.json | jq -r .aws_region)

rspec



