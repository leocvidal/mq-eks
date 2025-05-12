pipeline {
    agent any
    environment {
        IBM_ENTITLEMENT_KEY = credentials('ibm_entitlement_key')
        RELEASE_NAME        = "qm1"        
        NAMESPACE           = "mq1"
        STORAGE_CLASS       = "ocs-storagecluster-ceph-rbd"
        QMGR_NAME           = "QM1"
        CHANNEL_NAME        = "QM1CHL"
        LICENSE             = "L-JTPV-KYG8TF"
        METRIC              = "VirtualProcessorCore"
        USE                 = "NonProduction"
        VERSION             = "9.4.0.5-r2"
        AVAILABILITY        = "NativeHA"
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
            curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
            chmod 700 get_helm.sh
            ./get_helm.sh
            helm version
            '''
        }
        
        stage('Pre Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy '
                sh '/tmp/kubectl get pods'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                
            }
        }
    }
}
