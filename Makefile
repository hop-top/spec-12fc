# spec-12fc spec repo — local + CI tooling
#
# All targets idempotent, run from repo root. CI mirrors these in
# .github/workflows/validate.yml; keep them in sync.

PYTHON ?= python3
MARKDOWNLINT ?= markdownlint-cli2

MD_GLOBS := **/*.md \#node_modules

.PHONY: help lint lint-md test-scripts ci check-tools

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: lint-md ## Run every linter (markdown only — no schemas in this repo).

lint-md: ## Lint markdown via markdownlint-cli2.
	@command -v $(MARKDOWNLINT) >/dev/null 2>&1 || { \
		echo "error: $(MARKDOWNLINT) not found"; \
		echo "install: npm install --global markdownlint-cli2"; \
		exit 1; \
	}
	$(MARKDOWNLINT) $(MD_GLOBS)

test-scripts: ## Run unit tests for .github/scripts.
	$(PYTHON) -m unittest discover -s .github/scripts/tests -v

ci: lint test-scripts ## Run everything CI runs (lint + tests).

check-tools: ## Report which tools are installed.
	@printf 'python:        '; command -v $(PYTHON) || echo MISSING
	@printf 'markdownlint:  '; command -v $(MARKDOWNLINT) || echo MISSING
