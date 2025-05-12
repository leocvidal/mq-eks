#!/bin/bash
# © Copyright IBM Corporation 2021, 2022
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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export TARGET_NAMESPACE=${1:-"default"}
export MQCCDTURL="${DIR}/ccdt_generated.json"
export MQSSLKEYR="${DIR}/../../genericresources/createcerts/application"

export PORT="1414"
export IPADDRESS="$(kubectl get service secureapphelm-ibm-mq-loadbalancer -o jsonpath='{..ip}')"

( echo "cat <<EOF" ; cat ccdt_template.json ; echo EOF ) | sh > ccdt_generated.json


echo "Starting amqsghac" secureapphelm
/opt/mqm/samp/bin/amqsghac APPQ secureapphelm
