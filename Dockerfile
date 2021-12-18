ARG TF_VERSION=light

FROM pratikimprowise/upx as upx
FROM hashicorp/terraform:$TF_VERSION AS terraform

FROM node:16-alpine as ui
WORKDIR /src
COPY ./ui/package*.json ./
RUN npm set progress=false && npm config set depth 0 && npm install
COPY ./ui/public ./public
COPY ./ui/src ./src
RUN npm run build

FROM golang:1.17-alpine AS rover
COPY --from=upx / /
WORKDIR /src
RUN apk add --no-cache ca-certificates && update-ca-certificates
COPY go.* .
RUN go mod download
COPY . .
COPY --from=ui ./src/dist ./ui/dist
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags "-s -w"
RUN upx -9 rover

FROM scratch as release
WORKDIR /tmp
WORKDIR /src
COPY --from=terraform /bin/terraform  /usr/local/bin/terraform
COPY --from=rover     /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=rover     /src/rover      /usr/local/bin/rover
ENTRYPOINT [ "/bin/rover" ]
