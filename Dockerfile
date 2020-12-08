FROM google/cloud-sdk:alpine

ENV XDG_DATA_HOME=/helm3home

# Install openssl
RUN apk add --no-cache openssl
# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
RUN chmod +x get_helm.sh
RUN ./get_helm.sh -v v3.0.0
# Create Helm folder
RUN mkdir /helm3home
RUN chmod 775 -R /helm3home
# Install Helm GCS plugin 
RUN helm plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0
# Install yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 > /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq
# Install kubectl
RUN gcloud components install kubectl
# Copy scripts and make executable
COPY deploy.sh /deploy.sh
COPY applicationName.sh /applicationName.sh
RUN chmod +x /deploy.sh && chmod +x /applicationName.sh

WORKDIR /github/workspace/

ENTRYPOINT [ "/deploy.sh" ]
