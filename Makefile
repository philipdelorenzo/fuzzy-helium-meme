# NOTE: make help uses a special comment format to group targets.
# If you'd like your target to show up use the following:
#
# my_target: ##@category_name sample description for my_target
service := "helium"
service_title := "Helium API Client"
service_author := "Philip DeLorenzo"

default: help

############# Development Section #############
.PHONY: init
init: ##@development Installs needed prerequisites and software to develop the project
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -l scripts/init.sh -a
	@bash -l scripts/init.sh -p
	@asdf install
	@asdf reshim
	@echo "[INFO] - Installation Complete!"
	#@echo "[INFO] - To enter the poetry environment, run: 'poetry shell' from the '${service}' directory -- From here just type '${service}' to run the cli"
	#@echo "[INFO] - For ad-hoc cli commands run, 'poetry run ${service}' to run the cli outside of the poetry shell"

.PHONY: poetry-install
poetry-install: ##@development Installs poetry dependencies for the API client
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -c "cd helium || exit 1 && ./../.python/bin/poetry install"

.PHONY: encrypt-configs
encrypt-configs: ##@development Encrypts the configuration files
	$(info ********** Encrypting Configuration File **********)
	@if grep -Fxq '[sops]' mando/config.ini; then echo "Config file already encrypted"; exit 0; fi
	@sops --encrypt --in-place --encrypted-regex 'google|staging_database|staging_database_name|staging_database_port|staging_database_user|staging_database_password|production_database|production_database_name|production_database_port|production_database_user|production_database_password' --pgp `gpg --fingerprint "sreservice@manscaped.com" | grep pub -A 1 | grep -v pub | sed s/\ //g` mando/config.ini

.PHONY: decrypt-configs
decrypt-configs: ##@development Decrypts the configuration files
	$(info ********** Decrypting Configuration File **********)
	@sops --decrypt --in-place --ignore-mac mando/config.ini

.PHONY: lint format
isort: ##@code-quality Running isort on the project
	$(info ********** Decrypting Configuration File **********)
	@./.python/bin/python -m isort . --gitignore

format: ##@code-quality Running black on the project
	$(info ********** Running Black on the project **********)
	@./.python/bin/python -m black .

.PHONY: clean
clean: ##@misc Remove all build artifacts
	@echo "Cleaning up..."
	@rm -rf .python
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
