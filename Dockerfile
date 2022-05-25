FROM python:3.9-alpine 

LABEL maintainer=“lstrozzini@gmail.com”

ARG TERRAFORM_VERSION=1.2.1
ARG TERRAGRUNT_VERSION=0.37.1
ARG TFLINT_VERSION=0.36.2
ARG TFSEC_VERSION=1.21.2

ENV TF_PLUGIN_CACHE_DIR=/opt/terraform/plugins

RUN \
    apk --update add \
    bash \
    bash-completion \
    curl \
    groff \
    git \
    jq \
    less \
    openssh-client \
    tree \
    vim \
    wget \
    && \
    \
    pip3 install --upgrade awscli  s3cmd && \
    pip3 install --upgrade pytest && \
    \
    wget -q -O /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x /tmp/kubectl && \
    mv /tmp/kubectl /usr/local/bin && \
    \
    # Cleanup \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
RUN \
    wget -q -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip -q /tmp/terraform.zip -d /tmp && \
    chmod +x /tmp/terraform && \
    mv /tmp/terraform /usr/local/bin 

RUN wget -qO /tmp/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    chmod +x /tmp/terragrunt && \
    mv /tmp/terragrunt /usr/local/bin && \
    wget -qO /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip -q /tmp/tflint.zip -d /tmp && \
    chmod +x /tmp/tflint && \
    mv /tmp/tflint /usr/local/bin && \
    wget -qO /tmp/tfsec https://github.com/liamg/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 && \
    chmod +x /tmp/tfsec && \
    mv /tmp/tfsec /usr/local/bin 
RUN mkdir -p ${TF_PLUGIN_CACHE_DIR}/linux_amd64 && \
    aws --version && \
    kubectl version --client && \
    python3 --version && \
    terraform version  && \
    terragrunt -version && \
    tflint --version && \ 
    tfsec --version 

# Customisations
COPY *.sh /tmp/

RUN adduser -Ds /bin/bash awsuser

RUN . /tmp/10-tf-provider.sh && \
    \
    chmod -R 777 ${TF_PLUGIN_CACHE_DIR}
USER awsuser
RUN  . /tmp/20-bashrc.sh 
WORKDIR /home/awsuser 

ENTRYPOINT ["/bin/bash"]
