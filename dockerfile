# Stage 1: Build the app
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json .
COPY package-lock.json .

# Install dependencies
RUN npm install

# Copy application files
COPY . .

# Stage 2: Create a smaller production image
FROM node:20-slim

WORKDIR /app
# Copy the installed dependencies and application code from the builder stage
COPY --from=builder /app .

# Define the command to run the app
CMD ["node", "index.js"]