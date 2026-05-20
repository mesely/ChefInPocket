FROM ghcr.io/cirruslabs/flutter:stable AS frontend-build

WORKDIR /app/frontend

COPY frontend/pubspec.* ./
RUN flutter config --enable-web && flutter pub get

COPY frontend/ ./
RUN flutter build web --release

FROM node:20-alpine AS backend-deps

WORKDIR /app

COPY backend/ ./backend/

RUN set -eux; \
  for dir in /app/backend/api-gateway /app/backend/services/*; do \
    cd "$dir"; \
    npm install --omit=dev; \
  done

FROM node:20-alpine

RUN apk add --no-cache nginx

WORKDIR /app

COPY --from=backend-deps /app/backend ./backend
COPY --from=frontend-build /app/frontend/build/web /usr/share/nginx/html
COPY deploy/hf/nginx.conf /etc/nginx/http.d/default.conf
COPY deploy/hf/start.sh /app/start.sh

RUN chmod +x /app/start.sh

ENV PORT=7860
ENV API_GATEWAY_PORT=8080
ENV AUTH_SERVICE_PORT=5001
ENV RECIPE_SERVICE_PORT=5002
ENV PANTRY_SERVICE_PORT=5003
ENV COMMUNITY_SERVICE_PORT=5004
ENV ASSISTANT_SERVICE_PORT=5005
ENV CONTENT_SERVICE_PORT=5006

EXPOSE 7860

CMD ["/app/start.sh"]
