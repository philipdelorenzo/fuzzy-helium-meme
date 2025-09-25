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

### Deleting NodeGroups -- If you get into a bind in Terraform

`aws eks list-nodegroups --cluster-name my-eks-cluster --region <YOUR_REGION> --profile <AWS_PROFILE>`

`aws eks delete-nodegroup --cluster-name my-eks-cluster --nodegroup-name <NODEGROUP_NAME> --region <YOUR_REGION> --profile <AWS_PROFILE>`