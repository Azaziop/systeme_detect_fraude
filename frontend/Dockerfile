FROM nginx:stable-alpine

# Copy frontend files into nginx html folder
WORKDIR /usr/share/nginx/html

# Remove default nginx index if any and copy our files
RUN rm -rf ./*
COPY frontend/ .

# Expose nginx HTTP port
EXPOSE 80

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
