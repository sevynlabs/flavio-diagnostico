FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy project files to nginx html directory
COPY index.html /usr/share/nginx/html/index.html
COPY pagina-vendas-mentoria-master.html /usr/share/nginx/html/pagina-vendas-mentoria-master.html
COPY public/ /usr/share/nginx/html/public/

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
