FROM google/cloud-sdk

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
RUN chmod +x get_helm.sh

RUN ./get_helm.sh -v v2.15.2
RUN mv /usr/local/bin/helm /usr/local/bin/helm2
RUN helm2 init --client-only

RUN ./get_helm.sh -v v3.0.0
RUN mv /usr/local/bin/helm /usr/local/bin/helm3

RUN helm2 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0
RUN helm3 plugin install https://github.com/viglesiasce/helm-gcs.git --version v0.2.0

COPY deploy.sh /deploy.sh
RUN chmod +x /deploy.sh

WORKDIR /github/workspace/

ENTRYPOINT [ "/deploy.sh" ]
