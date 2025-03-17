# README

### Terraform

```hcl
terraform init
terraform apply -auto-approve
terraform init -auto-approve -migrate-state
terraform apply -auto-approve -lock=false
```

### AWS EKS

```sh
aws eks update-kubeconfig --region ap-southeast-1 --name mycluster

kubectl get nodes
```

### Artifactory OSS

```sh
helm repo add jfrog https://charts.jfrog.io

helm repo update

helm upgrade --install artifactory-oss jfrog/artifactory-oss \
    --version 107.98.10 \
    --namespace artifactory \
    --create-namespace

oc adm policy add-scc-to-user privileged -z default -n artifactory
```

### JCR Artifactory OSS

```sh
helm repo add jfrog https://charts.jfrog.io

helm repo update

helm upgrade --install jfrog-container-registry jfrog/artifactory-jcr \
    --version 107.98.10 \
    --namespace jcr \
    --create-namespace

oc adm policy add-scc-to-user privileged -z default -n jcr
```

### sonarqube

```sh
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube

helm repo update

helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube \
    --set OpenShift.enabled=true \
    --set postgresql.securityContext.enabled=false \
    --set postgresql.containerSecurityContext.enabled=false \
    --set edition=developer,monitoringPasscode="P@ssw0rd123" \
    --version 2025.1.0 \
    --namespace sonarqube \
    --create-namespace
```

### Gitlab

- intsall cert-manager operator
- install gitlab operator

```yaml
apiVersion: apps.gitlab.com/v1beta1
kind: GitLab
metadata:
  name: gitlab
  namespace: gitlab-system
spec:
  chart:
    values:
      certmanager:
        install: true
      certmanager-issuer:
        email: <your_email>@gmail.com
      gitlab:
        gitlab-shell:
          maxReplicas: 2
          minReplicas: 1
        sidekiq:
          maxReplicas: 2
          minReplicas: 1
          resources:
            requests:
              cpu: 500m
              memory: 1000M
        webservice:
          maxReplicas: 2
          minReplicas: 1
          resources:
            requests:
              cpu: 500m
              memory: 1500M
      global:
        hosts:
          domain: <your_domain>
        ingress:
          annotations:
            route.openshift.io/termination: edge
          class: none
      minio:
        resources:
          requests:
            cpu: 100m
      nginx-ingress:
        enabled: false
      postgresql:
        primary:
          extendedConfiguration: max_connections = 200
      redis:
        resources:
          requests:
            cpu: 100m
    version: 8.9.2
```

---

### Deploy Jboss

```sh
curl --location 'http://jboss.domain.com:9990/management' \
--digest -L --user admin:<PASSWORD> \
--header 'Content-Type: application/json' \
--data '{
    "operation": "composite",
    "address": [],
    "steps": [
        {
            "operation": "add",
            "address": {
                "deployment": "helloworld.war"
            },
            "content": [
                {
                    "url": "https://artifactory.domain.com/artifactory/helloworld-libs-release-local/org/jboss/eap/quickstarts/helloworld/8.0.0.GA/helloworld-8.0.0.GA.war"
                }
            ]
        },
        {
            "operation": "deploy",
            "address": {
                "deployment": "helloworld.war"
            }
        }
    ]
}'
```
