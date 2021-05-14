#!/usr/bin/env bash
ENVIRONMENT
echo ENVIRONMENT

case ENVIRONMENT in

  sandbox)
    AWS_ACCOUNT=090950721693
    ;;

  preview)
    AWS_ACCOUNT=090950721693
    ;;

  *)
    echo 'there is no account mapping for the specified environment: '
    exit 1
    ;;
esac

aws sts assume-role --output json --role-arn arn:aws:iam::ENVIRONMENT:role/DPSTerraformRole --role-session-name awspec-test > credentials

export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")
export AWS_DEFAULT_REGION=$(cat ENVIRONMENT.auto.tfvars.json | jq -r .aws_region)

rspec



