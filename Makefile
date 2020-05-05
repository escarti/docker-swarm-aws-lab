# Needed SHELL since I'm using zsh
SHELL := /bin/bash
.PHONY: help

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


TARGET_MAX_CHAR_NUM=20
## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Deploy all infrastructure
deploy_all:
	cd terraform/network; terraform apply -auto-approve;\
	cd ../swarm_members; terraform apply -auto-approve -var-file ../network/network.tfvars

## Destroy all infrastructure
destroy_all:
	cd terraform/swarm_members; terraform destroy -auto-approve -var-file ../network/network.tfvars; rm swarmec2.tfvars;\
	cd ../network; terraform destroy -auto-approve; rm network.tfvars;\
