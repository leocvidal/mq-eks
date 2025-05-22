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
    RELEASE_NAME={$7}
fi

echo "Soething..." 
echo $RELEASE_NAME
echo $MQ_ADMIN_PASSWORD_VALUE

cd samples/AWSEKS/deploy

QM_KEY=$(cat ../../genericresources/createcerts/server.key | base64 | tr -d '\n')
QM_CERT=$(cat ../../genericresources/createcerts/server.crt | base64 | tr -d '\n')
APP_CERT=$(cat ../../genericresources/createcerts/application.crt | base64 | tr -d '\n')

#( echo "cat <<EOF" ; cat mtlsqm.yaml_template ; echo EOF ) | sh > mtlsqm.yaml
eval "cat <<EOF
$(<mtlsqm.yaml_template)
EOF
" > mtlsqm.yaml

/tmp/kubectl create secret docker-registry ibm-entitlement-key \
  --docker-server=icr.io \
  --docker-username=cp \
  --docker-password=${6} \
  --docker-email=leo.vidal@au1.ibm.com \
  -n $TARGET_NAMESPACE

/tmp/kubectl config set-context --current --namespace=$TARGET_NAMESPACE

/tmp/kubectl apply -f mtlsqm.yaml

#/tmp/helm install secureapphelm ../../../charts/ibm-mq -f secureapp_nativeha.yaml $MQ_ADMIN_PASSWORD_NAME $MQ_ADMIN_PASSWORD_VALUE $MQ_APP_PASSWORD_NAME $MQ_APP_PASSWORD_VALUE $LB_ANNOTATION
/tmp/helm install "${RELEASE_NAME}" ../../../charts/ibm-mq -f secureapp_nativeha.yaml $MQ_ADMIN_PASSWORD_NAME $MQ_ADMIN_PASSWORD_VALUE $MQ_APP_PASSWORD_NAME $MQ_APP_PASSWORD_VALUE $LB_ANNOTATION
