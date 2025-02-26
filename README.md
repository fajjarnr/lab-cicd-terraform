# README

```sh
aws eks update-kubeconfig --region ap-southeast-1 --name mycluster
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

helm upgrade --install jfrog-container-registry frog/artifactory-jcr \
    --version 107.98.10 \
    --namespace jcr \
    --create-namespace

oc adm policy add-scc-to-user privileged -z default -n jcr
```

### sonarqube

```sh
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube

helm repo update

oc create namespace sonarqube

helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube \
    --set OpenShift.enabled=true \
    --set postgresql.securityContext.enabled=false \
    --set postgresql.containerSecurityContext.enabled=false \
    --set edition=developer,monitoringPasscode="P@ssw0rd123" \
    --version 2025.1.0
```
