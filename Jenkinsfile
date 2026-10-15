pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
  }

  triggers {
    pollSCM('H/5 * * * *')
  }

  environment {
    ACR_NAME  = 'acrshopstream2i5h5o'
    REGISTRY  = "${ACR_NAME}.azurecr.io"
    NAMESPACE = 'shopstream'
    APP_URL   = 'http://52.226.45.19'
  }

  stages {
    stage('Prepare') {
      steps {
        script {
          env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
        }
        echo "Building commit ${env.IMAGE_TAG}"
      }
    }

    stage('Unit tests') {
      steps {
        dir('app/backend') {
          sh '''
            python3 -m venv .venv
            .venv/bin/pip install --quiet -r requirements-dev.txt
            .venv/bin/pytest -q
          '''
        }
      }
    }

    stage('Build images') {
      steps {
        sh '''
          docker build -t $REGISTRY/shopstream/backend:$IMAGE_TAG app/backend
          docker build -t $REGISTRY/shopstream/frontend:$IMAGE_TAG app/frontend
        '''
      }
    }

    stage('Security scan') {
      steps {
        sh '''
          for img in backend frontend; do
            docker run --rm \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -v trivy-cache:/root/.cache \
              aquasec/trivy:latest image \
              --exit-code 1 --severity CRITICAL --ignore-unfixed --no-progress \
              $REGISTRY/shopstream/$img:$IMAGE_TAG
          done
        '''
      }
    }

    stage('Push to ACR') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'acr-push-sp',
                                          usernameVariable: 'ACR_USER',
                                          passwordVariable: 'ACR_PASS')]) {
          sh '''
            echo "$ACR_PASS" | docker login $REGISTRY -u "$ACR_USER" --password-stdin
            docker push $REGISTRY/shopstream/backend:$IMAGE_TAG
            docker push $REGISTRY/shopstream/frontend:$IMAGE_TAG
            docker logout $REGISTRY
          '''
        }
      }
    }

    stage('Deploy to AKS') {
      steps {
        withCredentials([file(credentialsId: 'aks-kubeconfig', variable: 'KUBECONFIG')]) {
          script {
            try {
              sh '''
                kubectl -n $NAMESPACE set image deployment/backend  backend=$REGISTRY/shopstream/backend:$IMAGE_TAG
                kubectl -n $NAMESPACE set image deployment/frontend frontend=$REGISTRY/shopstream/frontend:$IMAGE_TAG
                kubectl -n $NAMESPACE rollout status deployment/backend  --timeout=180s
                kubectl -n $NAMESPACE rollout status deployment/frontend --timeout=180s
                curl -fsS --retry 5 --retry-delay 3 --retry-connrefused $APP_URL/healthz
                curl -fsS --retry 5 --retry-delay 3 --retry-connrefused $APP_URL/api/orders
              '''
            } catch (err) {
              sh '''
                kubectl -n $NAMESPACE rollout undo deployment/backend
                kubectl -n $NAMESPACE rollout undo deployment/frontend
              '''
              error("Deploy failed and was rolled back: ${err}")
            }
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker image prune -f || true'
    }
  }
}