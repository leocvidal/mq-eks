# Deploying the IBM MQ Helm Chart on AWS EKS

## Pre-reqs
Prior to using the Helm chart you will need to install four dependencies:
1. [Helm version 3](https://helm.sh/docs/intro/install/)
2. [Kubectl](https://kubernetes.io/docs/tasks/tools/)
3. [AWS Command Line](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
4. Assure your AWS EKS Security Group allows communication on the assigned NodePorts.


## Installation
1. Log into the AWS EKS using the `aws` command line. If you are unsure how to do this please consult [here](https://aws.amazon.com/premiumsupport/knowledge-center/eks-cluster-connection/).
1. Change directories to *deploy*: `cd deploy`      
1. Run the installation command to deploy an instance of the helm chart: `./install.sh <namespace>`            
    Where \<namespace\> is the Kubernetes namespace where the resources should be deployed into. This will deploy a number of resources:
    * The IBM MQ Helm Chart using the properties within the [secureapp_nativeha.yaml](deploy/secureapp_nativeha.yaml) file.
    * A configMap with MQ configuration to define a default Queue, and the security required.
    * A secret that includes certificates and keys from the `genericresources/createcerts` directory. Assuring the communication in MQ is secure.
1. This will take a minute or so to deploy, and the status can be checked with the following command: `kubectl get pods | grep secureapp`. Wait until one of the three Pods is showing `1/1` under the ready status (only one will ever show this, the remainding two will be `0/1` showing they are replicas).

## Testing
Navigate to *../test* directory. No modifications should be required, as the endpoint configuration for your environment will be discovered automatically.

1. To initiate the testing, run the **./sendMessage.sh \<namespace\>** command. It will then connect to MQ and start sending messages immediately.

1. Open another terminal window and run the **./getMessage.sh \<namespace\>** command. You should see all of the messages being sent by the sendMessaging command.

1. To see how the pods work together in action, run the **kubectl get pod | grep secureapp** command on another terminal windows to view the current pods, and then delete the running pod (the one with the ready state of `1/1`) by running the command: **oc delete pod secureapphelm-ibm-mq-0** (where the pod name is customized based on which one is active). Once the active pod is deleted, the application connections will then reconnect to the other pod.

1. You can clean up the resources by navigating to the *../deploy* directory and running the command **./cleanup.sh \<namespace\>**. This will delete everything. Do not worry if you receive messages about PVCs not being found, this is a generic clean-up script and assumes a worst case scenario.
