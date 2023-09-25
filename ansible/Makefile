SHELL := /bin/bash

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Usage: make [Target] [Environment Variables]"
	@echo ""
	@echo "Targets:"
	@echo "  help             Show this help message"
	@echo "  install          Install ansible and ansible-lint"


.PHONY: install
install:
	# pip install -r requirements/requirements.txt
	ansible-galaxy collection install -r requirements/collections.yml
	ansible-galaxy install -r requirements/roles.yml

