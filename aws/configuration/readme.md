AWS - Configuration
============
All the necessary elements to fully configure AWS from the CLI

#### Configure source profile
```sh
# ---------------------
# configuration will appear in .aws/credentials
# - 
aws configure --profile "profile ${PROFILE}" set aws_access_key_id "${USER_AWS_KEY_ACCESS}"
aws configure --profile "profile ${PROFILE}" set aws_secret_access_key "${USER_AWS_KEY_SECRET}"
```

#### Configure child profile
```sh
# ---------------------
# configuration will appear in .aws/config
# - 
aws configure --profile "${WORKING_PROFILE}" set role_arn "${WORKING_PROFILE_ARN}"
aws configure --profile "${WORKING_PROFILE}" set source_profile "profile ${PROFILE}"
aws configure --profile "${WORKING_PROFILE}" set region "${REGION}"
aws configure --profile "${WORKING_PROFILE}" set output "${OUTPUT}"
```

## Kubeconfig - All In One

Append configuration int default Config file.

<sub>bash:<sub>
```sh
(aws eks update-kubeconfig --name "${CLUSTER_NAME}" --profile "${WORKING_PROFILE}" --alias "${ALIAS}") && (kubectl config set-context --current --namespace "${NAMESPACE}")  
```
<sub>powershell:<sub>
```ps
(aws eks update-kubeconfig --name "${CLUSTER_NAME}" --profile "${WORKING_PROFILE}" --alias "${ALIAS}") -and (kubectl config set-context --current --namespace "${NAMESPACE}")  
```

## Kubeconfig - Configuration Per Environment

Create separate configuration files per environment.  

<sub>bash:<sub>
```sh
(aws eks update-kubeconfig --name "${CLUSTER_NAME}" --kubeconfig "~/.kube/${ALIAS}" --profile "${WORKING_PROFILE}" --alias "${ALIAS}") && (kubectl --kubeconfig "~/.kube/${ALIAS}" config set-context --current --namespace "${NAMESPACE}")  
```

<sub>powershell:<sub>
```ps
(aws eks update-kubeconfig --name "${CLUSTER_NAME}" --kubeconfig "$env:USERPROFILE/.kube/${ALIAS}" --profile "${WORKING_PROFILE}" --alias "${ALIAS}") -and (kubectl --kubeconfig "$env:USERPROFILE/.kube/${ALIAS}" config set-context --current --namespace "${NAMESPACE}")  
```

## Tips

In case when you trying to connect into EKS from heavy secured comapny, you need to use some proxy settings.

```sh
export no_proxy=localhost,127.0.0.0,127.0.1.1,127.0.1.1,local.home,.https://eks.amazonaws.com,.https://organization.com,organization.com
```
You can use [px](https://github.com/genotrance/px) tool to sustain proxy connection.

```ps
taskkill /F /IM px.exe
timeout 1
Start-Process -NoNewWindow -FilePath %USERPROFILE%/Downloads/px.exe
$env:HTTP_PROXY="http://localhost:3128"
$env:HTTPS_PROXY="http://localhost:3128"
$Env:no_proxy="localhost,127.0.0.0,127.0.1.1,127.0.1.1,local.home,.eks.amazonaws.com,"   
```

