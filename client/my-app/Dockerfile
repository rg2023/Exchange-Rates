FROM node:16 as builder

WORKDIR /app
COPY package*.json ./


# ARG VITE_BACKEND_URL
# ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

COPY . .
RUN npm install
RUN npm run build




FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80




# FROM node:16

# # Set the working directory in the container
# WORKDIR /app

# # Copy package.json and package-lock.json to the working directory
# COPY package*.json ./



# ARG VITE_BACKEND_URL
# ENV VITE_BACKEND_URL=$VITE_BACKEND_URL

# # Install app dependencies
# RUN npm install

# # Copy the rest of your application code to the working directory
# COPY . .

# # Expose a port to communicate with the React app
# EXPOSE 5173

# # Start your React app
# CMD ["npm", "run", "dev"]