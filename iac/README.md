# AWS IAC

This is the IaC directory for all provisioning required for the Helium API Client application.

## STOP!

You need to have your `aws` CLI configured to use an user with access in the AWS account to create the resources needed for this app.

```bash
aws configure --profile <your-aws-user>
```

Create a .aws_profile file in `iac` root directory with the name of the profile _(user)_ you wish to use to run the Terraform commands.

```bash
echo "<my-aws-profile-name>" >> .aws_profile
```

You will also need to create a .doppler file as well in the `iac` root, this will allow the user to get secret variables locally.

```bash
echo "<your-doppler-token>" >> .doppler
```

## Bootstrapping -- s3 Remote State Bucket _(Backend)_

Once you have attained your doppler token, and placed it in the `.doppler` file, and added your AWS User _(Profile)_ to the `.aws_profile`, you will
now be able to provision your backend:

### _TL;DR Developer Experience_

The Makefile provides much smaller commands to run, for the basic usage that injects the needed variables from Doppler into the environment. This also runs the
commands with the `--profile <your-profile>` in the terraform commands _(which ensures that 'default' doesn't trip you up)_.

If you need to run ad-hoc commands, you can just copy the commands in the Makefile and run them directly, as long as you have the environment variables set in the SHELL.

From the `iac` directory:

```bash
make fmt
```

```bash
make validate
```

```bash
make bootstrap
```

```bash
make init
```

```bash
make plan
```

```bash
make apply
```

```bash
make destroy
```

## Ad-Hoc Commands

If you run into an issue where the secret will not delete due to the grace period:


##### Remove Secret

`aws secretsmanager delete-secret --secret-id helium-dev-db-credentials --force-delete-without-recovery --profile <your-aws-profile>`

#### Check to ensure your AuroraDB is not publicly accessible

`aws rds describe-db-instances --query 'DBInstances[*].PubliclyAccessible' --profile <your-aws-profile>`

It should return `[false]`.
