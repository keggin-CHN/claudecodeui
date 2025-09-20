# --- Build Stage ---
# Use Node.js 20, which is required by the dependencies.
FROM node:20-alpine AS build

# Set the working directory
WORKDIR /app

# Install system dependencies required for native module compilation (like node-pty)
# This installs Python, make, g++, etc.
RUN apk add --no-cache python3 build-base

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies using 'npm ci' for reliability
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Build the frontend application
RUN npm run build

# --- Production Stage ---
# Use the same Node.js 20 base for the production environment
FROM node:20-alpine

WORKDIR /app

# Only copy the necessary files from the build stage for a smaller, more secure image.
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/server ./server
COPY --from=build /app/dist ./dist

# Expose the port the server listens on
EXPOSE 3000

# The command to run the application
CMD ["npm", "run", "start"]
