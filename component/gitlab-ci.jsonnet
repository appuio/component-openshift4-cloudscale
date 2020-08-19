local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_cloudscale;

{
  'gitlab-ci': {
    stages: [
      'validate',
      'plan',
      'deploy',
    ],
    default: {
      image: params.images.terraform.image + ':' + params.images.terraform.tag,
      tags: params.gitlab_ci.tags,
      before_script: [
        'cd ${TF_ROOT}',
        'gitlab-terraform init',
      ],
      cache: {
        key: '${CI_PIPELINE_ID}',
        paths: [
          '${TF_ROOT}/.terraform/modules',
          '${TF_ROOT}/.terraform/plugins',
        ],
      },
    },
    variables: {
      TF_ROOT: '${CI_PROJECT_DIR}/manifests/openshift4-cloudscale',
      TF_ADDRESS: '${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/cluster',
      CLOUDSCALE_TOKEN: '${CLOUDSCALE_TOKEN_RO}',
    },
    validate: {
      stage: 'validate',
      script: [
        'gitlab-terraform validate',
      ],
    },
    format: {
      stage: 'validate',
      before_script: [],
      cache: {},
      script: [
        'terraform fmt -recursive -diff -check ${TF_ROOT}',
      ],
    },
    plan: {
      stage: 'plan',
      script: [
        'gitlab-terraform plan',
        'gitlab-terraform plan-json',
      ],
      artifacts: {
        name: 'plan',
        paths: [
          '${TF_ROOT}/plan.cache',
        ],
        expire_in: '1 week',
        reports: {
          terraform: '${TF_ROOT}/plan.json',
        },
      },
    },
    apply: {
      stage: 'deploy',
      environment: {
        name: 'production',
      },
      variables: {
        CLOUDSCALE_TOKEN: '${CLOUDSCALE_TOKEN_RW}',
      },
      script: [
        'gitlab-terraform apply',
      ],
      dependencies: [
        'plan',
      ],
      when: 'manual',
      only: [
        'master',
      ],
    },
  },
}
