# EKS Cluster

Here are some useful commands you will need to work with the cluster.

### Connect Kubectl

From the `/iac` directory root:

```bash
CURDIR="$(pwd)"
export DOPPLER_TOKEN="$(cat ${CURDIR}/.doppler)"
export AWS_PROFILE="$(cat ${CURDIR}/.aws_profile)"

doppler run --token ${DOPPLER_TOKEN} --command 'aws eks update-kubeconfig --region ${AWS_REGION} --name my-eks-cluster --profile ${AWS_PROFILE}'

unset CURDIR
unset DOPPLER_TOKEN
unset AWS_PROFILE
```
