# Local Kubernetes Cluster

`cd` into the `iac/local/terraform` directory and run:

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

If you run into an issue where you get stuck, or something happens to the state file (local).

You can manually delete the cluster using the kind CLI:

```bash
kind delete cluster --name "helium-cluster"
```
