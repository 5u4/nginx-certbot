domain=$1
email=${2:-"alexwongsenhung@gmail.com"}

if [ -z $domain ]
then
echo Domain is not specified
exit 1
fi

if [ -z $(pwd)/sites/index.html ]
then
mkdir $(pwd)/sites
fi

cp -f $(pwd)/templates/temporary.conf $(pwd)/temp/default.conf

if [ -z $(pwd)/sites/index.html ]
then
cp $(pwd)/templates/index.html $(pwd)/sites/index.html
fi

sed -i -E "s/0x3fc.com;$/$domain;/" $(pwd)/temp/default.conf

docker run -it --name temp-nginx -p 80:80 -p 443:443 \
    -v $(pwd)/temp/default.conf:/etc/nginx/conf.d/default.conf \
    -v $(pwd)/dhparam/dhparam-2048.pem:/etc/ssl/certs/dhparam-2048.pem \
    -v $(pwd)/sites:/usr/share/nginx/html \
    -d nginx:alpine

docker run -it --rm \
    -v $(pwd)/certbot/etc/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/certbot/var/lib/letsencrypt:/var/lib/letsencrypt \
    -v $(pwd)/sites:/data/letsencrypt \
    -v $(pwd)/certbot/var/log/letsencrypt:/var/log/letsencrypt \
    certbot/certbot \
    certonly --webroot \
    --email $email --agree-tos --no-eff-email \
    --webroot-path=/data/letsencrypt \
    -d $domain

docker rm temp-nginx -f
