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
	@bash -c "cd helium || exit 1 && ./../.python/bin/poetry install"

poetry-run: ##@development Installs poetry dependencies for the API client
	$(info ********** Installing Developer Tooling Prerequisites **********)
	@bash -c "./.python/bin/poetry --directory helium run python helium/main.py"

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
