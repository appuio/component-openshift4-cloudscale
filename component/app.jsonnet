local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_cloudscale;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('openshift4-cloudscale', params.namespace);

{
  'openshift4-cloudscale': app,
}
