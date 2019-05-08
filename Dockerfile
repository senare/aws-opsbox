FROM java:8-jdk-alpine
ENV AWSCLI_VERSION 1.16.22
ENV KUBE_AWS_RELEASE v0.9.8
ENV KUBECTL_VERSION v1.12.0

RUN apk update \
    && apk add --no-cache unzip curl tar bash zip \
    python make bash vim jq  \
    openssl openssh-client sshpass  \
    gcc libffi-dev python-dev musl-dev openssl-dev py-pip py-virtualenv \
    git coreutils less bash-completion \
    libc6-compat && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/bash_completion.d/ /etc/profile.d/

RUN set -x && \
    apk add --update libintl && \
    apk add --virtual build_deps gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Install kubectl
RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl && \
    kubectl completion bash > /etc/bash_completion.d/kubectl.sh

# Install kube-aws
RUN curl --fail -sSL -O https://github.com/kubernetes-incubator/kube-aws/releases/download/${KUBE_AWS_RELEASE}/kube-aws-linux-amd64.tar.gz && \
    tar xzf kube-aws-linux-amd64.tar.gz && \
    mv linux-amd64/kube-aws /usr/local/bin/kube-aws && \
    chmod +x /usr/local/bin/kube-aws && \
    rm -rf linux-amd64/ && \
    rm -f kube-aws-linux-amd64.tar.gz

# Install aws cli bundle
RUN pip install awscli==${AWSCLI_VERSION} boto && \
    rm -rf /root/.cache && \
    find / -type f -regex '.*\.py[co]' -delete && \
    ln -s /usr/local/aws/bin/aws_bash_completer /etc/bash_completion.d/aws.sh && \
    ln -s /usr/local/aws/bin/aws_completer /usr/local/bin/

# Install aws-iam-authenticator
RUN curl -L -o /usr/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /usr/bin/aws-iam-authenticator

# Install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/bin && \
    chmod +x /usr/bin/eksctl

# Install Helm
ENV VERSION v2.13.1
ENV FILENAME helm-${VERSION}-linux-amd64.tar.gz
ENV HELM_URL https://storage.googleapis.com/kubernetes-helm/${FILENAME}

RUN curl -o /tmp/$FILENAME ${HELM_URL} \
  && tar -zxvf /tmp/${FILENAME} -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp

# Install envsubst [better than using 'sed' for yaml substitutions]
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Install Helm plugins
RUN helm init --client-only

# Plugin is downloaded to /tmp, which must exist
RUN mkdir /tmp
RUN helm plugin install https://github.com/viglesiasce/helm-gcs.git
RUN helm plugin install https://github.com/databus23/helm-diff

COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    mkdir /mnt/opsbox && \
    ln -s /mnt/opsbox/.aws /root/.aws && \
    ln -s /mnt/opsbox/.kube /root/.kube

WORKDIR /opsbox

VOLUME ["/opsbox", "/mnt/opsbox"]

ENTRYPOINT ["/start.sh"]
