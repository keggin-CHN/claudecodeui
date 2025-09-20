# --- Build Stage ---
# Use a Node.js LTS version for the build environment
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the frontend application
RUN npm run build

# --- Production Stage ---
# Use a smaller, more secure Node.js image for the production environment
FROM node:18-alpine

WORKDIR /app

# Copy dependencies and server code from the build stage
COPY --from-build /app/package*.json ./
COPY --from-build /app/node_modules ./node_modules
COPY --from-build /app/server ./server

# Copy the built frontend assets from the build stage
COPY --from-build /app/dist ./dist

# Expose the port the server listens on
EXPOSE 3000

# The command to run the application
CMD ["npm", "run", "start"]
