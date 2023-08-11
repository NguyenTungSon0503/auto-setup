# Install Nginx
sudo apt update
sudo apt-get install -y nginx
sudo systemctl status nginx

sudo add-apt-repository ppa:certbot/certbot
sudo apt update
sudo apt install -y certbot

source ./env.sh
sudo letsencrypt certonly -a webroot \
  -w /var/www/html/ecom \
  -d $DOMAIN_HOST -d www.$DOMAIN_HOST

sudo ls -l  /etc/letsencrypt/live/$DOMAIN_HOST
sudo -E DOMAIN_HOST=$DOMAIN_HOST -E bash -c 'cat << EOF > /etc/nginx/snippets/ssl-'$DOMAIN_HOST'.conf
ssl_certificate /etc/letsencrypt/live/$DOMAIN_HOST/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_HOST/privkey.pem;
EOF'

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
sudo bash -c 'cat << EOF > /etc/nginx/snippets/ssl-params.conf
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

ssl_dhparam /etc/ssl/certs/dhparam.pem;
EOF'


source ./env.sh
#User
cd
cd E-commerce-User
npm run build
sudo rm -rf /etc/nginx/sites-available/default
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /var/www/html/ecom
sudo scp -r ./build /var/www/html/ecom
sudo -E DOMAIN_HOST=$DOMAIN_HOST -E bash -c 'cat << EOF > /etc/nginx/sites-available/ecom
server {
  listen 80;
  listen [::]:80;

  server_name $DOMAIN_HOST www.$DOMAIN_HOST;

    root /var/www/html/ecom;
    index index.html;
  location / {
    try_files $uri /index.html;
  }

  location /api/ {
    proxy_pass http://'$IP':5000;
    proxy_read_timeout 300;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_cache_bypass $http_upgrade;
 }

  if ($http_x_forwarded_proto = "http") {
      return 301 https://\$server_name\$request_uri;
  }

}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name $DOMAIN_HOST;
    
    include snippets/ssl-$DOMAIN_HOST.conf;
    include snippets/ssl-params.conf;

    root /var/www/html/ecom;
    index index.html;
  location / {
    try_files $uri /index.html;
  }

  location /api/ {
    proxy_pass http://'$IP':5000;
    proxy_read_timeout 300;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_cache_bypass $http_upgrade;
 }

}

EOF'
sudo ln -s /etc/nginx/sites-available/ecom /etc/nginx/sites-enabled/ 
sudo systemctl restart nginx

#Admin
cd
cd E-commerce-Admin
npm run build
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /var/www/html/admin
sudo scp -r ./build /var/www/html/admin
sudo bash -c 'cat << EOF > /etc/nginx/sites-enabled/admin
server {
  listen 81;
  listen [::]:81;
  server_name localhost;

  location / {
    root /var/www/html/admin;
    index index.html;
    try_files \$uri /index.html;
  }

  location /api/ {
    proxy_pass http://'$IP':5000;
 }
}
EOF'
sudo systemctl restart nginx

