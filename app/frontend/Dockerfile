FROM nginxinc/nginx-unprivileged:1.27-alpine

# Pull in OS security patches that are newer than the base image tag
USER root
RUN apk upgrade --no-cache
USER 101

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080