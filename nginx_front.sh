# Install Nginx
sudo apt update
sudo apt-get install -y nginx
sudo systemctl status nginx

source ./env.sh
#User
cd
cd E-commerce-User
npm run build
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /var/www/html/ecom
sudo scp -r ./build /var/www/html/ecom
sudo bash -c 'cat << EOF > /etc/nginx/sites-enabled/ecom
server {
  listen 80;
  listen [::]:80;
  server_name localhost;

  location / {
    root /var/www/html/ecom;
    index index.html;
    try_files \$uri /index.html;
  }

  location /api/ {
    proxy_pass http://'$IP':5000;
 }

}
EOF'
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

