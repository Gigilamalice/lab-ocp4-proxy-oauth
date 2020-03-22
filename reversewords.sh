#!/bin/sh
echo "Hello World"
oc create namespace reverse-words-oauth
oc project reverse-words-oauth
oc -n reverse-words-oauth create -f deployment.yaml
oc -n reverse-words-oauth create -f service.yaml
oc -n reverse-words-oauth create route edge reverse-words --service=reverse-words --port=app --insecure-policy=Redirect
oc status

