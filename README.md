<div align="center">
    <h1>Nginx Certbot</h1>
    <span>Let's Encrypt SSL + nginx + docker</span>
</div>

## Before All

Generate `dbparam`

```bash
touch $(pwd)/dhparam/dhparam-2048.pem
```

```bash
docker run -it --rm -v $(pwd)/dhparam:/data frapsoft/openssl dhparam -out /data/dhparam-2048.pem 2048
# Or if openssl is installed:
# openssl dhparam -out $(pwd)/dhparam/dhparam-2048.pem 2048
```

## Scripts

**⚠️ Important: Scripts should be ran on repo root path**

### Create a certificate

```bash
# Execute step 3, 4, 5
./scripts/cert.sh <domain> <email> <current-nginx-container-name>
```

### Renew

```bash
./scripts/renew.sh <current-nginx-container-name>
```

Set up cron job for auto renew certificates

```bash
crontab -e
```

```
0 6 * * * cd /home/senhung/Workspace/nginx-certbot && ./scripts/renew.sh
```

NOTE: Replace `/home/senhung/Workspace/nginx-certbot` to your folder location

## Directories

You can alias the following directories

### Nginx

<!-- prettier-ignore -->
```
nginx
├─ nginx.conf
└─ conf.d
    └─ default.conf
```

### Sites

<!-- prettier-ignore -->
```
sites
└─ index.html
```

## Detailed Steps

1. Create temporary nginx server

```bash
mkdir $(pwd)/sites
cp -f $(pwd)/templates/temporary.conf $(pwd)/temp/default.conf
cp $(pwd)/templates/index.html $(pwd)/sites/index.html
```

Change the server name `0x3fc.com` to the desired domain in `./temp/default.conf`

```bash
docker run -it --name temp-nginx -p 80:80 -p 443:443 \
    -v $(pwd)/temp/default.conf:/etc/nginx/conf.d/default.conf \
    -v $(pwd)/dhparam/dhparam-2048.pem:/etc/ssl/certs/dhparam-2048.pem \
    -v $(pwd)/sites:/usr/share/nginx/html \
    -d nginx:alpine
```

1. Generate certificate using certbot

```bash
docker run -it --rm \
    -v $(pwd)/certbot/etc/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/certbot/var/lib/letsencrypt:/var/lib/letsencrypt \
    -v $(pwd)/sites:/data/letsencrypt \
    -v $(pwd)/certbot/var/log/letsencrypt:/var/log/letsencrypt \
    certbot/certbot \
    certonly --webroot \
    --email alexwongsenhung@gmail.com --agree-tos --no-eff-email \
    --webroot-path=/data/letsencrypt \
    -d 0x3fc.com
```

NOTE: Replace `alexwongsenhung@gmail.com` to your own email and `0x3fc.com` to your own domain. For multiple domains add `-d ...`

1. Remove temporary nginx server

```bash
docker rm temp-nginx -f
```

1. Create the ssl nginx server

```bash
mkdir $(pwd)/nginx
mkdir $(pwd)/sites
cp -r $(pwd)/templates/conf.d $(pwd)/nginx
cp $(pwd)/templates/nginx.conf $(pwd)/nginx/nginx.conf
cp $(pwd)/templates/index.html $(pwd)/sites/index.html
```

Change the server name `0x3fc.com` to the desired domains in `./nginx/default.conf`

```bash
docker run -it --name nginx -p 80:80 -p 443:443 --restart=always \
    -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d \
    -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf \
    -v $(pwd)/dhparam/dhparam-2048.pem:/etc/ssl/certs/dhparam-2048.pem \
    -v $(pwd)/sites:/usr/share/nginx/html \
    -v $(pwd)/certbot/etc/letsencrypt:/etc/letsencrypt \
    -d nginx:alpine
```

NOTE: Replace `0x3fc.com` to your own domains.

## Reference

[How to Set Up Free SSL Certificates from Let's Encrypt using Docker and Nginx](https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx)
