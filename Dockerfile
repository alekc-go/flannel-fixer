FROM golang:alpine AS build-env
ADD . /src
RUN cd /src && go build -o flannel-fixer

FROM alpine as final
RUN apk add --no-cache ca-certificates
COPY --from=build-env /src/flannel-fixer /bin/flannel-fixer

USER nobody

