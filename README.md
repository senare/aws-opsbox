# aws-opsbox

# Description

Docker image with installed CLI tools: `java`, `aws`, `kubectl`, `aws-iam-authenticator` , `kube-aws`, `eksctl`

# Versions

* Java     `8`
* AWSCLI   `1.16.22`
* Kubectl  `v1.12.0`
* Kube-AWS `v0.9.8`
* eksctl   `0.1.31`

# Basic usage

```
docker run --rm itsvit/opsbox aws help
docker run --rm itsvit/opsbox kubectl --help
```

# Advanced usage

```
docker run -ti -v ${HOME}/.opsbox -v ${PWD}:/opsbox itsvit/opsbox kubectl get po --all-namespaces
docker run -ti -v ${HOME}/.opsbox -v ${PWD}:/opsbox itsvit/opsbox aws ec2 describe-instances --region us-west-2
```


# Creating an EKS cluster

```
eksctl create cluster --name=demo-eks-cluster --nodes=2 --region=us-west-2
```

#### Verify cluster is there ...
```
kubectl get nodes
```



