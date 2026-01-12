SHELL := /bin/bash
.DEFAULT_GOAL := help

# Virtual environment
VENV := .venv

# Default site
SITE ?= malati

.PHONY: help
help: ## Show this help
	@echo "Usage: make [target] [SITE=malati|arpigesh]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make install                          # Install ansible + deps"
	@echo "  source $(VENV)/bin/activate           # Activate venv"
	@echo "  make ping SITE=malati                 # Test connection"
	@echo "  make bootstrap SITE=malati HOST=malati-pi"
	@echo "  make site SITE=malati                 # Full deployment"

.PHONY: install
install: ## Install ansible and dependencies using uv
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "ERROR: uv not found. Install: curl -LsSf https://astral.sh/uv/install.sh | sh"; \
		exit 1; \
	fi
	uv sync
	source $(VENV)/bin/activate && ansible-galaxy install -r requirements.yml --force

.PHONY: clean
clean: ## Remove virtual environment and ansible cache
	rm -rf $(VENV) .ansible/cache

.PHONY: ping
ping: ## Test connection to site hosts
	ansible all -i inventories/$(SITE)/hosts.yml -m ping

.PHONY: check
check: ## Check system status
	ansible-playbook playbooks/maintenance/check.yml -i inventories/$(SITE)/hosts.yml

.PHONY: update
update: ## Run system updates
	ansible-playbook playbooks/maintenance/update.yml -i inventories/$(SITE)/hosts.yml

.PHONY: reboot
reboot: ## Reboot hosts
	ansible-playbook playbooks/maintenance/reboot.yml -i inventories/$(SITE)/hosts.yml

.PHONY: bootstrap
bootstrap: ## Bootstrap new host (requires HOST=hostname)
	@if [ -z "$(HOST)" ]; then echo "ERROR: HOST required. Usage: make bootstrap SITE=malati HOST=malati-pi"; exit 1; fi
	ansible-playbook playbooks/bootstrap.yml -i inventories/$(SITE)/hosts.yml -l $(HOST)

.PHONY: services
services: ## Deploy infrastructure services
	ansible-playbook playbooks/services.yml -i inventories/$(SITE)/hosts.yml --ask-vault-pass

.PHONY: apps
apps: ## Deploy applications
	ansible-playbook playbooks/apps.yml -i inventories/$(SITE)/hosts.yml

.PHONY: site
site: ## Full site deployment
	ansible-playbook playbooks/site.yml -i inventories/$(SITE)/hosts.yml --ask-vault-pass

.PHONY: vault-edit
vault-edit: ## Edit vault secrets for site
	ansible-vault edit inventories/$(SITE)/group_vars/vault.yml

.PHONY: vault-encrypt
vault-encrypt: ## Encrypt vault file for site
	ansible-vault encrypt inventories/$(SITE)/group_vars/vault.yml

.PHONY: lint
lint: ## Run ansible-lint on playbooks
	ansible-lint playbooks/
