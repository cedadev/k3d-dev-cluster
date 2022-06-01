DOMAIN=127.0.0.1.nip.io
-include local/Makefile

up-full:
	$(MAKE) init
	$(MAKE) up
	$(MAKE) install-postgresql

up:
	-$(MAKE) create-registry
	k3d cluster create \
		--config k3d-default.yaml \
		--registry-use registry.$(DOMAIN):12345
	$(MAKE) install-nginx-ingress
	$(MAKE) install-dashboard

down:
	k3d cluster delete

init:
	-helm plugin install https://github.com/aslafy-z/helm-git

create-registry:
	k3d registry create \
		registry.$(DOMAIN) \
		-p 12345

install-nginx-ingress:
	-kubectl create namespace ingress-nginx
	-kubectl create secret \
		--namespace ingress-nginx \
		tls \
		$(DOMAIN) \
		--key local/$(DOMAIN)/privkey.pem \
		--cert local/$(DOMAIN)/fullchain.pem
	helm upgrade \
		--install \
		--wait \
		ingress-nginx \
		ingress-nginx \
		--repo https://kubernetes.github.io/ingress-nginx \
		--namespace ingress-nginx \
		--create-namespace \
		--set controller.ingressClassResource.default=true \
		--set controller.extraArgs.default-ssl-certificate="ingress-nginx/$(DOMAIN)"

install-dashboard:
	helm upgrade \
		--install \
		--wait \
		kubernetes-dashboard \
		kubernetes-dashboard \
		--namespace kubernetes-dashboard \
		--create-namespace \
		--repo https://kubernetes.github.io/dashboard/ \
		--set ingress.enabled=true \
		--set ingress.hosts[0]=kdash.$(DOMAIN) \
		--set extraArgs[0]=--enable-skip-login
	kubectl create \
		clusterrolebinding \
		kubernetes-dashboard \
		--clusterrole=cluster-admin \
		--serviceaccount=kubernetes-dashboard:kubernetes-dashboard

install-postgresql:
	helm upgrade \
		--install \
		--wait \
		postgresql \
		postgresql \
		--repo https://charts.bitnami.com/bitnami \
		--namespace postgresql \
		--create-namespace \
		--set global.postgresql.auth.postgresPassword=postgres

shell:
	kubectl run \
		toolbox \
		--rm \
		--tty -i \
		--restart='Never' \
		--image docker.io/fedora:latest \
		--command /usr/bin/bash
