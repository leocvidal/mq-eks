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
        stage('Pre Deploy') {
            steps {
                echo 'Pre-Deploy ~ setup configuration before deploy '

            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy ~ deploy queue manager'
                
            }
        }
    }
}
