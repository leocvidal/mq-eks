#! /bin/bash
# © Copyright IBM Corporation 2021, 2023
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


TARGET_NAMESPACE=${1:-default}


if [ $# -gt 2 ]
  then
    MQ_ADMIN_PASSWORD_NAME="--set queueManager.envVariables[0].name=MQ_ADMIN_PASSWORD"
    MQ_ADMIN_PASSWORD_VALUE="--set queueManager.envVariables[0].value=${2}"
    MQ_APP_PASSWORD_NAME="--set queueManager.envVariables[1].name=MQ_APP_PASSWORD"
    MQ_APP_PASSWORD_VALUE="--set queueManager.envVariables[1].value=${3}"
fi
if [ $# -eq 4 ]
  then
    LB_ANNOTATION="--set-string route.loadBalancer.annotations.service\.beta\.kubernetes\.io/aws-load-balancer-internal=${4}"
fi

cd samples/AWSEKS/deploy
echo "running aws eks .." 
#export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
#export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
aws eks update-kubeconfig --region us-east-1 --name itzeks-694000l4zn-go9v59qq

echo "running /tmp/kubectl config set-context:"
/tmp/kubectl config set-context --current --namespace=$TARGET_NAMESPACE
/tmp/kubectl get pods

export QM_KEY=$(cat ../../genericresources/createcerts/server.key | base64 | tr -d '\n')
export QM_CERT=$(cat ../../genericresources/createcerts/server.crt | base64 | tr -d '\n')
export $APP_CERT=$(cat ../../genericresources/createcerts/application.crt | base64 | tr -d '\n')
echo $QM_KEY
echo $QM_CERT
echo $APP_CERT

( echo "cat <<EOF" ; cat mtlsqm.yaml_template ; echo EOF ) | sh > mtlsqm.yaml

#/tmp/kubectl config set-context --current --namespace=$TARGET_NAMESPACE
#/tmp/kubectl apply -f mtlsqm.yaml

# /tmp/helm install secureapphelm ../../../charts/ibm-mq -f secureapp_nativeha.yaml $MQ_ADMIN_PASSWORD_NAME $MQ_ADMIN_PASSWORD_VALUE $MQ_APP_PASSWORD_NAME $MQ_APP_PASSWORD_VALUE $LB_ANNOTATION
