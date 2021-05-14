#!/usr/bin/env bash

ENVIRONMENT=$1

cat <<EOF > environment.yml
---
version: 2.1

orbs:
  terraform: feedyard/terraform@0.5.0

workflows:
  version: 2
  lab-platform-vpc-pipeline:

    jobs:
      - terraform/plan:
          name: ${ENVIRONMENT}-change-plan
          context: twdps-di
          shell: secrethub run -- /bin/sh -eo pipefail
          workspace: ${ENVIRONMENT}
          before-terraform:
            - run:
                name: generate environment configuration and credentials from templates
                command: |
                  secrethub inject -i tpl/terraformrc.tpl -o ~/.terraformrc
                  secrethub inject -i environments/${ENVIRONMENT}.auto.tfvars.json.tpl -o ${ENVIRONMENT}.auto.tfvars.json

      - approve-changes:
          name: approve-${ENVIRONMENT}-changes
          type: approval
          requires:
            - ${ENVIRONMENT}-change-plan

      - terraform/apply:
          name: ${ENVIRONMENT}-change-apply
          context: twdps-di
          shell: secrethub run -- /bin/sh -eo pipefail
          workspace: ${ENVIRONMENT}
          before-terraform:
            - run:
                name: generate environmental configuration and credentials from templates
                command: |
                  secrethub inject -i tpl/terraformrc.tpl -o ~/.terraformrc
                  secrethub inject -i environments/${ENVIRONMENT}.auto.tfvars.json.tpl -o ${ENVIRONMENT}.auto.tfvars.json
                  secrethub inject -i tpl/vpc.test.sh.tpl -o vpc.test.sh
          after-terraform:
            - run:
                name: test environment changes
                environment:
                  TEST_ENV: ${ENVIRONMENT}
                command: |
                  cat vpc.test.sh
                  secrethub run -- bash vpc.test.sh ${ENVIRONMENT}
          requires:
            - approve-${ENVIRONMENT}-changes
EOF
