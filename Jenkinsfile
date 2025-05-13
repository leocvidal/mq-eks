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
        stage('Pre Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy '
                
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                sh '''
                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                /tmp/awscli/v2/2.27.14/bin/aws eks update-kubeconfig --region us-east-1 --name itzeks-694000l4zn-go9v59qq
                '''
                // sh('./samples/AWSEKS/deploy/install_jenkins.sh ${NAMESPACE}') //
            }
        }
    }
}
