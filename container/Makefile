# DOCKER TASKS
# Build the container
APP_NAME=capable
DOCKER_REPO=quay.io/xymox
# VERSION=ibm2
VERSION=0.7
DOCKER=podman

prepare:
	@cp ../golang/ocipidinfo ../capabilities-tracker ../capabilities_tracker.json ../capable-hook .
  
pre-clean:
	@rm -f ocipidinfo capabilities_tracker capabilities-tracker.json capable-hook

build: prepare ## Build the container
	$(DOCKER) build -t $(APP_NAME) -f Dockerfile.fedora .

build-nc: prepare ## Build the container without caching
	$(DOCKER) build --no-cache -t $(APP_NAME) -f Dockerfile.fedora .

run: ## Run container on port configured in `config.env`
	$(DOCKER) run -i -t --rm --env-file=./config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)


up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	$(DOCKER) stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
publish: publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR

publish-latest: tag-latest ## Publish the `latest` taged container to ECR
	@echo 'publish latest to $(DOCKER_REPO)'
	$(DOCKER) push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to ECR
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	$(DOCKER) push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	$(DOCKER) tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	$(DOCKER) tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# HELPERS

version: ## Output the current version
	@echo $(VERSION)
