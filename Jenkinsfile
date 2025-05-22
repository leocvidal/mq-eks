pipeline {
    agent any
    environment {
        IBM_ENTITLEMENT_KEY     = credentials('ibm_entitlement_key')
        AWS_ACCESS_KEY_ID       = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY   = credentials('AWS_SECRET_ACCESS_KEY')
        MQ_ADMIN_PASSWORD_VALUE = credentials('MQ_ADMIN_PASSWORD_VALUE')
        RELEASE_NAME          = "qm1"        
        NAMESPACE             = "qm1"
        STORAGE_CLASS         = "ocs-storagecluster-ceph-rbd"
        QMGR_NAME             = "QM1"
        CHANNEL_NAME          = "QM1CHL"
        LICENSE               = "L-JTPV-KYG8TF"
        METRIC                = "VirtualProcessorCore"
        USE                   = "NonProduction"
        VERSION               = "9.4.0.5-r2"
        AVAILABILITY          = "NativeHA"
        PATH = "${HOME}/.local/bin:${PATH}"
        LOG_DIR = 'logs'
        SCRIPT_DIR = 'scripts'
        CONFIG_DIR = 'configs'
        OUTPUT_DIR = 'outputs'
    }
    stages {
        stage('Prepare Workspace') {
            steps {
                sh '''
                mkdir -p $LOG_DIR $OUTPUT_DIR
                '''
            }
        }
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

        stage('Install jq') {
            steps {
                echo 'Donwload kubectl '
                sh '''
                JQ_BIN="/tmp/jq"
                if ! command -v jq &> /dev/null; then
                echo "Downloading jq..."
                curl -L -o $JQ_BIN https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
                chmod +x $JQ_BIN
                fi
               
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
                '''
            }
        }

        stage('Install aws cli') {
            steps {
                echo 'Install aws cli '
                sh '''
                    set +x
                    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o -q awscliv2.zip
                    ./aws/install --bin-dir $HOME/.local/bin --install-dir $HOME/.local/aws-cli --update
                    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
                    . ~/.bashrc
                    export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                    aws eks update-kubeconfig --region us-east-1 --name itzeks-694000l4zn-go9v59qq
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
                sh('./samples/AWSEKS/deploy/install_jenkins.sh ${NAMESPACE} ${MQ_ADMIN_PASSWORD_VALUE} ${AVAILABILITY} ${VERSION} ${QMGR_NAME} ${IBM_ENTITLEMENT_KEY} ${RELEASE_NAME}')
        
            }
        }
        stage('Post Deploy') {
        steps {
            script {
            echo 'Apply mqsc config'
            def errorLog = "${LOG_DIR}/mqsc_errors.log"
            sh """
                echo '⏳ Waiting for Load Balancer to be ready...'
                sleep 10
                /tmp/kubectl get svc ${RELEASE_NAME}-ibm-mq-loadbalancer -o wide
                LB=\$(/tmp/kubectl get service ${RELEASE_NAME}-ibm-mq-loadbalancer -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
                ./samples/AWSEKS/deploy/run_mqsc.sh ${MQ_ADMIN_PASSWORD_VALUE} samples/AWSEKS/deploy/commands.mqsc "\$LB" ${errorLog} ${RELEASE_NAME}
            """
            }
        }
        post {
            always {
            archiveArtifacts artifacts: "${LOG_DIR}/*.log", onlyIfSuccessful: false
            }
        }
        }
    }
}
