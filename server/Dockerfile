ARG GO_VERSION=1.23.0
ARG ALPINE_VERSION=3.20
ARG PNPM_VERSION=8.7.6
ARG NODE_VERSION=20.11.0
# --------------------------------------------

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} as go-builder

WORKDIR /go/src/jeweler

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o api cmd/main.go

# --------------------------------------------

FROM node:${NODE_VERSION}-alpine as pnpm-setup

RUN npm install -g pnpm@${PNPM_VERSION}

WORKDIR /usr/src/jeweler

COPY jeweler/package.json jeweler/pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

# --------------------------------------------

FROM alpine:${ALPINE_VERSION}

WORKDIR /usr/src/jeweler

COPY --from=go-builder /go/src/jeweler/api api
COPY --from=go-builder /go/src/jeweler/.env .env
RUN chmod +x "/usr/src/jeweler/api"

COPY --from=pnpm-setup /usr/local/bin/pnpm /usr/local/bin/pnpm
COPY --from=pnpm-setup /usr/src/jeweler/node_modules ./node_modules
COPY --from=pnpm-setup /usr/src/jeweler/package.json ./package.json
COPY --from=pnpm-setup /usr/src/jeweler/pnpm-lock.yaml ./pnpm-lock.yaml

ENTRYPOINT ["/usr/src/jeweler/api"]