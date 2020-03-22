#!/bin/sh

echo
echo Using OpenShift OAuth Proxy to secure your Applications on OpenShift
echo https://linuxera.org/oauth-proxy-secure-applications-openshift/
echo

echo "Hello World Oauth"
oc create namespace reverse-words-oauthv2
oc project reverse-words-oauthv2
oc create -f deployment-oauth.yaml
oc create -f service-oauth.yaml
echo "- STEP 2 -"
oc create serviceaccount reversewords
oc create secret generic reversewords-proxy --from-literal=session_secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c43)
oc annotate serviceaccount reversewords serviceaccounts.openshift.io/oauth-redirectreference.reversewords='{"kind":"OAuthRedirectReference","apiVersion":"v1","reference":{"kind":"Route","name":"reverse-words-authenticated"}}'

echo "- STEP 3 -"
echo
# oc create route edge      reverse-words               --service=reverse-words --port=app --insecure-policy=Redirect
oc create route reencrypt reverse-words-authenticated --service=reverse-words --port=proxy --insecure-policy=Redirect
echo


curl -I https://$(oc get route reverse-words-authenticated -o jsonpath='{.status.ingress[*].host}') -k

#
# Annexes - Add access only for users belong to namespace : reverse-words-oauth
#
# - -openshift-service-account=reversewords
# - -openshift-sar={"resource":"namespaces","resourceName":"reverse-words-oauth","namespace":"reverse-words-oauth","verb":"get"}
#