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

## Deploy SWARM infrastructure
deploy_swarm:
	cd terraform/network; terraform apply -auto-approve;\
	cd ../swarm_members; terraform apply -auto-approve -var-file ../network/network.tfvars

## Deploy FARGATE infrastructure
deploy_fargate:
	cd terraform/network; terraform init; terraform apply -auto-approve;\
	cd ../fargate; terraform init; terraform apply -auto-approve -var-file ../network/network.tfvars

## Destroy all infrastructure
destroy_all:
	cd terraform/swarm_members; terraform init; terraform destroy -auto-approve -var-file ../network/network.tfvars; rm swarmec2.tfvars; rm *.tfstate; rm *.backup;\
	cd ../fargate; terraform init; terraform destroy -auto-approve -var-file ../network/network.tfvars; rm fargate.tfvars; rm *.tfstate; rm *.backup;\
	cd ../network; terraform init; terraform destroy -auto-approve; rm network.tfvars; rm *.tfstate; rm *.backup;\

## Destroy swarm infrastructure
swarm_destroy:
	cd terraform/swarm_members; terraform destroy -auto-approve -var-file ../network/network.tfvars; rm swarmec2.tfvars;

## Destroy network infrastructure
network_destroy:
	cd terraform/network; terraform destroy -auto-approve; rm network.tfvars;

## Format all terraform files
fmt_all:
	cd terraform/network; terraform fmt;\
	cd ../fargate; terraform fmt;\
	cd ../swarm_members; terraform fmt;\

