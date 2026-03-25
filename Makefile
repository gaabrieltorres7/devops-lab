APP = devops-lab

.PHONY: setup-dev teardown-dev deploy-dev dev

setup-dev:
	@echo "Creating cluster $(APP)..."
	@which helm > /dev/null 2>&1 || (curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash)
	@kind create cluster --name $(APP) --config k8s/config/config.yaml
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@kubectl wait --namespace ingress-nginx \
	--for=condition=ready pod \
	--selector=app.kubernetes.io/component=controller \
	--timeout=270s
	@helm repo add bitnami https://charts.bitnami.com/bitnami
	@helm repo update
	@helm dependency update k8s/charts/postgres/
	@helm install postgres k8s/charts/postgres/ \
		--set postgresql.auth.password=secret \
		--set postgresql.auth.username=docker \
		--set postgresql.auth.database=db_dev
	@echo "Cluster $(APP) is ready!"

teardown-dev:
	@echo "Deleting cluster $(APP)..."
	@kind delete cluster --name $(APP)
	@echo "Done."

deploy-dev:
	@echo "Deploying application to cluster $(APP)..."
	@docker build -t $(APP):latest .
	@kind load docker-image $(APP):latest --name $(APP)
	@kubectl apply -f k8s/manifests
	@kubectl wait --namespace default \
	--for=condition=ready pod \
	--selector=app=$(APP) \
	--timeout=120s
	@kubectl exec deployment/$(APP) -- npx prisma migrate deploy
	@kubectl rollout restart deployment/$(APP)
	@echo "Application deployed to cluster $(APP)!"

dev: setup-dev deploy-dev