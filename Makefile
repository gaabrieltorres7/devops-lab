APP = devops-lab

.PHONY: setup-dev teardown-dev

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
	@helm install postgres k8s/charts/postgres/
	@echo "Cluster $(APP) is ready!"

teardown-dev:
	@echo "Deleting cluster $(APP)..."
	@kind delete cluster --name $(APP)
	@echo "Done."