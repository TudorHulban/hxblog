hxgo_info_color := \033[0;32m
hxgo_no_color := \033[0m

hxgo_linting := .linting
hxgo_golangci_lint_ver := 2.9.0

.DEFAULT_GOAL := lint

${hxgo_linting}:
	mkdir -p ${hxgo_linting}

install-golangci-lint: ${hxgo_linting}
	@echo -e "$(hxgo_info_color)==> $@ $(hxgo_no_color)"
	@if [ -f "${hxgo_linting}/golangci-lint" ] && "${hxgo_linting}/golangci-lint" --version >/dev/null 2>&1; then \
		echo "golangci-lint is already installed"; \
	else \
		echo "golangci-lint not found or not executable, installing v${hxgo_golangci_lint_ver}..."; \
		rm -f "${hxgo_linting}/golangci-lint"; \
		curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b ${hxgo_linting} v${hxgo_golangci_lint_ver} || { echo "Failed to install golangci-lint"; exit 1; }; \
		echo "Installed golangci-lint, version: $$("${hxgo_linting}/golangci-lint" --version 2>&1)" || { echo "Failed to verify golangci-lint version"; exit 1; }; \
	fi

deps: install-golangci-lint
	@echo -e "$(hxgo_info_color)==> $@ $(hxgo_no_color)"

hxgo_linting := .linting

lint: deps
	@${hxgo_linting}/golangci-lint config path
	@${hxgo_linting}/golangci-lint config verify
	@${hxgo_linting}/golangci-lint run --config ${PWD}/.golangci.yaml

test:
	@echo -e "$(hxgo_info_color)==> $@ $(hxgo_no_color)"
	@go test ./... -race -count=1 -v

test-local: 
	@go test -failfast -count=1 ./... -json -cover -race | tparse -smallscreen

# --------------------------------------------------------------
# Database
# --------------------------------------------------------------

DB_NAME ?= tara_blog
DB_User ?= postgres
DB_Password ?= password-box

pg-local:
	@docker run -d --name=co-postgres -p 5471:5432 \
	-e POSTGRES_USER=$(DB_User) \
	-e POSTGRES_PASSWORD=$(DB_Password) \
	-e POSTGRES_DB=$(DB_NAME) \
	postgres:18.2-bookworm

migrations-local:
	@docker run --rm \
	--net="host" -v ./migrations:/flyway/sql \
	flyway/flyway:8.2.2 \
	-community \
	-url="jdbc:postgresql://localhost:5471/$(DB_NAME)" \
	-user="$(DB_User)" \
	-password="$(DB_Password)" \
	migrate