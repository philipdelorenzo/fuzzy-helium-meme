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

From the `iac` directory:

```bash
make bootstrap
```
