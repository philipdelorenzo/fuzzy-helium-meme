# NOTE: make help uses a special comment format to group targets.
# If you'd like your target to show up use the following:
#
# my_target: ##@category_name sample description for my_target
service := "helium"
service_title := "Helium API Client"
service_author := "Philip DeLorenzo"
DOPPLER_TOKEN := $(shell cat .doppler)
AWS_PROFILE := $(shell cat .aws_profile)
default: help

# We need to have a doppler token set to proceed, this is by design so that bad actors cannot access the secrets, or environments.
define TOKEN_ALIVE_SCRIPT
[[ -f .doppler ]] && cat .doppler || echo "false"
endef
export TOKEN_ALIVE_SCRIPT

DOPPLER_TOKEN := $$(bash -c "$$TOKEN_ALIVE_SCRIPT")

define DTOKEN_EVAL
[[ "${DOPPLER_TOKEN}" == "false" ]] && echo "The .doppler file is missing, please set the Doppler token in this file." || echo 0
endef
export DTOKEN_EVAL

IS_TOKEN := $$(bash -c "$$DTOKEN_EVAL")

############# Development Section #############
.PHONY: prereqs bootstrapinit
prereqs:
	@bash -l "scripts/prereqs.sh"

bootstrap: ##@development Bootstraps the development environment
	$(info ********** Bootstrapping Development Environment (Creating AWS s3 Backend) **********)
	@$(MAKE) prereqs
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/bootstrap || exit 1 && terraform init"
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/bootstrap || exit 1 && terraform plan -out=tfplan -var='profile=${AWS_PROFILE}'"
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/bootstrap || exit 1 && terraform apply tfplan"
	@echo "[INFO] - Bootstrap Complete!"

init: ##@development Installs needed prerequisites and software to develop the project
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@$(MAKE) prereqs
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/terraform/environments/dev || exit 1 && terraform init -backend-config='profile=${AWS_PROFILE}'"

validate: ##@development Validates the terraform files
	$(info ********** Validating Terraform Files **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/terraform/environments/dev || exit 1 && terraform validate"

plan: ##@development Plans the terraform changes to be applied
	$(info ********** Planning Terraform Changes **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/terraform/environments/dev || exit 1 && terraform plan -out=tfplan -var='profile=${AWS_PROFILE}'"

apply: ##@development Applies the terraform changes to be applied
	$(info ********** Applying Terraform Changes **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/terraform/environments/dev || exit 1 && terraform apply tfplan"
	@echo "[INFO] - Terraform Apply Complete!"

destroy: ##@development Destroys all terraform-managed infrastructure
	$(info ********** Destroying All Terraform-Managed Infrastructure **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "cd aws/terraform/environments/dev || exit 1 && terraform destroy -var='profile=${AWS_PROFILE}'"

help: ##@misc Show this help.
	@echo $(MAKEFILE_LIST)
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

# helper function for printing target annotations
# ripped from https://gist.github.com/prwhite/8168133
HELP_FUNC = \
	%help; \
	while(<>) { \
		if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
			push(@{$$help{$$2}}, [$$1, $$3]); \
		} \
	}; \
	print "usage: make [target]\n\n"; \
	for ( sort keys %help ) { \
		print "$$_:\n"; \
		printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
		print "\n"; \
	}
