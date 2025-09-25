# Github Action Workflows

### Dry Labeled Workflows

The workflow manifests that are labeled with `dry-` are `workflow_call` events
that are essentially actions that are broken out into their own manifests.

Singlular runs, or dispatches, are labeled with an `adhoc-` prefix.

### Initial Release

Once the first PR is created, the codebase will create the first version.

## GithubOIDCRole

In the IAM (AWS), or in Terraform - you will need an IAM Role that allows connections
from AWS to Github through OIDC. You will need to give the policy access to the repos:

Example: Trust Relationship should looks something as follows...

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": [
                        "repo:philipdelorenzo/fuzzy-helium-meme:*",
                        "<repo:add-other-repo-here:*>"
                    ]
                }
            }
        }
    ]
}
```

Add a role and attach to the above:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:<REGION>:<ACCOUNT_ID>:cluster/<CLUSTER_NAME>"
        }
    ]
}
```
