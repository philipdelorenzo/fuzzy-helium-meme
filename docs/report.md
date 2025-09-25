# Synopsis Report

The basic design here is least permissive, but the part I like about the design is that the Doppler token also acts as a sort-of-a "kill switch". So, this essentially means that any breach, etc. at the very least can be met with a token roll. If that be the case, the "bad actor" is back to square one trying to get in.

Even if a token is acquired - they have read access, but they cannot see the actual secrets as they're injected at runtime into the Docker container. Even if they gain access, the Docker container is not rooted so they won't be able to get access to those secrets that way either.

Everything is build with Iac, bootstrapping code, etc. But the main concept is that the Github repo is really the root of the ecosystem. Everything is defined, maintained, and diseminated from there _(Gitops workflow)_. I didn't have the time but I was going to implement FluxCD _(this simple app doesn't require the complexity of ArgoCD IMHO)_ to monitor the ECR repo, and new versions would be deployed to Kubernetes. Also, depending on the requirements, either a B/G, Canary or a combination of the two would be utilized.

The database is NOT open to the public, so a bastion host, etc. would be required. For local development, I added some logic to change connections strings and use a local PostgreSQL instance for development, testing, etc. Normally I would add Liveness, Readiness, and Startups but I just didn't have the time. The VPC can access the database via a security group or you could add host IPs to a whitelist, or something along those lines _(in a pinch)_. 

There is a lot in this repo, but the idea was to show how I work _(issues, projects, PR's, small commits, conventional commits, documentation, mermaid diagrams and flowcharts, etc.)_ and to also show my passion for automation, toil reduction, redundancy reduction _(Makefile)_, secrets management _(Doppler, no more need for .env files floating around - if a laptop is lost or stolen, regardless of the maturity of the org managing it, all of the secrets are compromised)_.

Doppler is separate from AWS - so even if someone gains access to AWS, they still cannot do as much damage because the secrets to the actual data is in another aspect of the ecosystem.

Developer experience is impacted positively as developers don't have to do as much _"setup/bones/scaffoling"_ types of things, or maintenance. Those are taken care of by the SRE/Platform team.

**NOTE**: For my own repos, applications, etc. I have my own CLI _(Python Click)_ that has all of the github actions in a separate repo, which via a command in the CLI will update your repo's actions with the latest version. This way, SRE/Platform doesn't have to interupt Developent/Workflows with SRE/Platform related PR's that adds context switching to a developer's workday, etc.

