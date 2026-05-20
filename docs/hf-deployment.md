# Hugging Face Deployment

This project can be deployed to a Hugging Face Docker Space with a single root-level `Dockerfile`.

## What the Docker image does

- Builds the Flutter frontend for the web
- Installs all backend microservice dependencies
- Starts the five backend services and the API gateway inside one container
- Serves the Flutter web app through Nginx on port `7860`
- Proxies `/api/*` requests to the internal API gateway

## Before you upload

1. Create a new Hugging Face Space and choose the `Docker` SDK.
2. Add `MONGODB_URI` as a Space secret.
3. Upload the whole repository, including the root `Dockerfile`.

## Local smoke test

```bash
docker build -t chefinpocket-hf .
docker run --rm -p 7860:7860 -e MONGODB_URI="your_mongodb_uri" chefinpocket-hf
```

Then open:

- `http://localhost:7860`
- `http://localhost:7860/health`

## Frontend API calls

When you wire the Flutter UI to the backend, use relative paths such as:

- `/api/auth/login`
- `/api/recipes`
- `/api/pantry/ingredients`

That way the same frontend works both locally and on Hugging Face without changing hostnames.
