FROM oven/bun:latest
ARG NODE_ENV
ARG VITE_BASE_URL
ENV NODE_ENV=${NODE_ENV:-production}
ENV VITE_BASE_URL=${VITE_BASE_URL:-http://localhost:3000}
WORKDIR /app
COPY . .
RUN bun run combined:build
EXPOSE 3000
CMD bun run combined:run
