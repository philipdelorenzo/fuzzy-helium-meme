# NOTE: make help uses a special comment format to group targets.
# If you'd like your target to show up use the following:
#
# my_target: ##@category_name sample description for my_target
service := "helium"
service_title := "Helium API Client"
service_author := "Philip DeLorenzo"

default: help

# We need to have a doppler token set to proceed, this is by design so that bad actors cannot access the secrets, or environments.
define TOKEN_ALIVE_SCRIPT
[[ -f .doppler ]] && cat .doppler || echo "false"
endef
export TOKEN_ALIVE_SCRIPT

DOPPLER_TOKEN := $$(bash -c "$$TOKEN_ALIVE_SCRIPT")

define DTOKEN_EVAL
[[ "${DOPPLER_TOKEN}" == "false" ]] && echo "[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file." || echo 0
endef
export DTOKEN_EVAL

IS_TOKEN := $$(bash -c "$$DTOKEN_EVAL")

############# Development Section #############
.PHONY: init prereqs all build clean poetry-install poetry-run isort format clean-all
prereqs:
	$(info ********** Checking Developer Tooling Prerequisites **********)
	@if [[ ${IS_TOKEN} == '[CRITICAL] - The .doppler file is missing, please set the Doppler token in this file.' ]]; then echo "${IS_TOKEN}" && exit 1; fi
	@bash -l "scripts/prereqs.sh"

init: ##@development Installs needed prerequisites and software to develop the project
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -l scripts/init.sh -a
	@bash -l scripts/init.sh -p
	@asdf install
	@asdf reshim
	@echo "[INFO] - Installation Complete!"

all: ##@development Runs all the development steps
	$(info ********** Running All Development Steps **********)
	@$(MAKE) init
	@$(MAKE) poetry-install
	@$(MAKE) poetry-run

build: ##@development Builds the Docker image for the API client
	$(info ********** Building the Docker Image **********)
	@bash -c "cd helium || exit 1 && ./../.python/bin/poetry export -f requirements.txt --without-hashes -o production.txt"
	@cd helium || exit 1 && docker build -t fuzzyheliummeme/${service}:latest .
	@$(MAKE) clean
	@echo "[INFO] - Docker image build for ${service_title} Complete!"

clean: ##@development Cleans up the development environment
	$(info ********** Cleaning Up the Development Environment **********)
	@rm -rf helium/production.txt

.PHONY: poetry-install
poetry-install: ##@development Installs poetry dependencies for the API client
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -c ".python/bin/poetry --directory helium install"

poetry-run: prereqs ##@development Installs poetry dependencies for the API client
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@doppler run --token ${DOPPLER_TOKEN} --command "./.python/bin/poetry --directory helium run python helium/main.py --local"

.PHONY: lint format
isort: ##@code-quality Running isort on the project
	$(info ********** Running Isort on the project **********)
	@./.python/bin/python -m isort . --gitignore

format: ##@code-quality Running black on the project
	$(info ********** Running Black on the project **********)
	@./.python/bin/python -m black .

.PHONY: clean
clean-all: ##@misc Remove all build artifacts
	@echo "Cleaning up..."
	@rm -rf .python
	@rm -rf helium/production.txt
	@echo "Cleaned up!"

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
