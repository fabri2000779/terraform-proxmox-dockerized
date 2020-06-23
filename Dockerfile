FROM hashicorp/terraform:0.12.26 AS scalefast-terraform-base

LABEL maintainer="Architects <architects@scalefast.com>"

ENV GOLANG_VERSION 1.13.12

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		musl-dev \
		openssl \
		go \
	; \
	export \

GOROOT_BOOTSTRAP="$(go env GOROOT)" \

GOOS="$(go env GOOS)" \
GOARCH="$(go env GOARCH)" \
GOHOSTOS="$(go env GOHOSTOS)" \
GOHOSTARCH="$(go env GOHOSTARCH)" \
; \

apkArch="$(apk --print-arch)"; \
case "$apkArch" in \
	armhf) export GOARM='6' ;; \
	armv7) export GOARM='7' ;; \
	x86) export GO386='387' ;; \
esac; \
\
wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
echo '17ba2c4de4d78793a21cc659d9907f4356cd9c8de8b7d0899cdedcef712eba34 *go.tgz' | sha256sum -c -; \
tar -C /usr/local -xzf go.tgz; \
rm go.tgz; \
\
cd /usr/local/go/src; \
./make.bash; \
\
rm -rf \

# Install proxmox plugin
/usr/local/go/pkg/bootstrap \

	/usr/local/go/pkg/obj \
; \
apk del .build-deps; \
\
export PATH="/usr/local/go/bin:$PATH"; \
go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN go get -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox

RUN go get -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox

RUN go install -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox

RUN go install -v github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox

COPY $GOPATH/bin/terraform-provider-proxmox /usr/local/bin/

COPY $GOPATH/bin/terraform-provisioner-proxmox /usr/local/bin/