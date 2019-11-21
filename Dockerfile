FROM google/cloud-sdk

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
RUN chmod +x get_helm.sh

RUN ./get_helm.sh -v v2.15.2
RUN mv /usr/local/bin/helm /usr/local/bin/helm2
RUN mkdir /helm2home
ENV HELM_HOME=/helm2home
RUN helm2 init --client-only
RUN helm2 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0
RUN chmod 775 -R /helm2home

RUN ./get_helm.sh -v v3.0.0
RUN mv /usr/local/bin/helm /usr/local/bin/helm3
RUN mkdir /helm3home
ENV XDG_DATA_HOME=/helm3home
RUN helm3 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0
RUN chmod 775 -R /helm3home

RUN curl -L https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 > /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq

COPY deploy.sh /deploy.sh
RUN chmod +x /deploy.sh
COPY applicationName.sh /applicationName.sh
RUN chmod +x /applicationName.sh

WORKDIR /github/workspace/

ENTRYPOINT [ "/deploy.sh" ]
