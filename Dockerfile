FROM ghcr.io/gohugoio/hugo:v0.168.0 AS build
COPY --chown=hugo:hugo . /project
RUN hugo build --minify

FROM nginx:1.29-alpine
COPY --from=build /project/public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
