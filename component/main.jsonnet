local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_cloudscale;

{
  'main.tf': {
    module: {
      cluster: params.variables,
    },
  },
  'backend.tf': {
    terraform: {
      backend: {
        http: {},
      },
    },
  },
  'output.tf': {
    output: {
      cluster_dns: {
        value: '${module.cluster.dns_entries}',
      },
    },
  },
  'variables.tf': {
    variable: {
      ignition_bootstrap: {
        default: '',
      },
    },
  },
}
