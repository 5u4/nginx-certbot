# Stop main nginx
docker stop nginx

# Start a temp nginx server that accepts the challenge on port 80
docker run -it --name temp-nginx -p 80:80 -p 443:443 \
    -v $(pwd)/temp/default.conf:/etc/nginx/conf.d/default.conf \
    -v $(pwd)/dhparam/dhparam-2048.pem:/etc/ssl/certs/dhparam-2048.pem \
    -v $(pwd)/sites:/usr/share/nginx/html \
    -d nginx:alpine

# Renew certificate with certbot
docker run --rm -it --name certbot \
    -v $(pwd)/certbot/etc/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/certbot/var/lib/letsencrypt:/var/lib/letsencrypt \
    -v $(pwd)/sites:/data/letsencrypt \
    -v $(pwd)/certbot/var/log/letsencrypt:/var/log/letsencrypt \
    certbot/certbot renew \
    --webroot -w /data/letsencrypt --quiet

# Kill the renew
docker kill --signal=HUP temp-nginx

# Remove temp nginx server
docker rm temp-nginx -f

# Restart nginx
docker start nginx
