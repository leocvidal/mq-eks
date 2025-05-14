pipeline {
    agent any
    environment {
        IBM_ENTITLEMENT_KEY   = credentials('ibm_entitlement_key')
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        RELEASE_NAME          = "qm1"        
        NAMESPACE             = "ibm-mq-ns"
        STORAGE_CLASS         = "ocs-storagecluster-ceph-rbd"
        QMGR_NAME             = "QM1"
        CHANNEL_NAME          = "QM1CHL"
        LICENSE               = "L-JTPV-KYG8TF"
        METRIC                = "VirtualProcessorCore"
        USE                   = "NonProduction"
        VERSION               = "9.4.0.5-r2"
        AVAILABILITY          = "NativeHA"
    }
    stages {
        stage('Download kubectl') {
            steps {
                echo 'Donwload kubectl '
                sh '''
                curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl"
                chmod +x kubectl
                mv kubectl /tmp/kubectl
               
                '''
            }
        }

        stage('Install Helm') {
            steps {
                echo 'Install helm '
                sh '''
                    HELM_VERSION="v3.14.4"
                    curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
                    tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz
                    mv linux-amd64/helm /tmp/helm
                    chmod +x /tmp/helm
                    /tmp/helm version
                '''
            }
        }

        stage('Install aws cli') {
            steps {
                echo 'Install aws cli '
                sh '''
                    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    ./aws/install --bin-dir $HOME/.local/bin --install-dir $HOME/.local/aws-cli --update
                    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
                    . ~/.bashrc
                    export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                    aws eks update-kubeconfig --region us-east-1 --name itzeks-694000l4zn-go9v59qq
                    /tmp/kubectl get pods
                '''
            }    
        }

        stage('Pre Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy '
                
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                sh '''
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


                echo "Current namespace: ${TARGET_}NAMESPACE}" 

                aws help 
                /tmp/kubectl config set-context --current --namespace=$TARGET_NAMESPACE

                export QM_KEY=$(cat ../../genericresources/createcerts/server.key | base64 | tr -d '\n')
                export QM_CERT=$(cat ../../genericresources/createcerts/server.crt | base64 | tr -d '\n')
                export APP_CERT=$(cat ../../genericresources/createcerts/application.crt | base64 | tr -d '\n')
                '''
                //sh('./samples/AWSEKS/deploy/install_jenkins.sh ${NAMESPACE}')//
            }
        }
    }
}
