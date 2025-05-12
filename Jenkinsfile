pipeline {
      agent {
        kubernetes {
          yaml """
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: kubectl
        image: bitnami/kubectl:latest
        command:
        - cat
        tty: true
    """
        }
      }
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
        stage('Pre Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy '
                sh 'kubectl get pods'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                
            }
        }
    }
}
