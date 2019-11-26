FROM google/cloud-sdk:alpine

COPY deploy.sh /deploy.sh
COPY applicationName.sh /applicationName.sh
ENV HELM_HOME=/helm2home
ENV XDG_DATA_HOME=/helm3home
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh &&\
 apk add --no-cache openssl &&\
 chmod +x get_helm.sh &&\
 ./get_helm.sh -v v2.15.2 &&\
 mv /usr/local/bin/helm /usr/local/bin/helm2 &&\
 mkdir /helm2home &&\
 helm2 init --client-only &&\
 helm2 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0 &&\
 chmod 775 -R /helm2home &&\
 ./get_helm.sh -v v3.0.0 &&\
 mv /usr/local/bin/helm /usr/local/bin/helm3 &&\
 mkdir /helm3home &&\
 helm3 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0 &&\
 chmod 775 -R /helm3home &&\
 curl -L https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 > /usr/local/bin/yq &&\
 chmod +x /usr/local/bin/yq &&\
 gcloud components install kubectl &&\
 chmod +x /deploy.sh &&\
 chmod +x /applicationName.sh

WORKDIR /github/workspace/

ENTRYPOINT [ "/deploy.sh" ]
