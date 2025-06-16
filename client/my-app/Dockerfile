FROM node:16 as builder

WORKDIR /app
COPY package*.json ./



COPY . .
RUN npm install
RUN npm run build

# ARG VITE_BACKEND_URL
# ENV VITE_BACKEND_URL=$VITE_BACKEND_URL


FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80



