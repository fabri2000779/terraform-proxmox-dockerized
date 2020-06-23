FROM golang:1.13.12-alpine3.12 AS scalefast-golang-base

LABEL maintainer="Architects <architects@scalefast.com>"


ENV TERRAFORM_VERSION 0.12.26

RUN apk --update --no-cache add libc6-compat git curl zip unzip

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN go get -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox

RUN go get -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox

RUN go install -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox

RUN go install -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox

RUN mv $GOPATH/bin/terraform-provider-proxmox /usr/local/bin/

RUN mv $GOPATH/bin/terraform-provisioner-proxmox /usr/local/bin/

WORKDIR /work

CMD ["terraform"]