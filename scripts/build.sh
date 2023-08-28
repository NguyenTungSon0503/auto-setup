sudo apt update
sudo apt-get install -y nginx
sudo systemctl status nginx

cd
cd E-commerce-User
npm run build
sudo rm -rf /etc/nginx/sites-available/default
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /var/www/html/ecom
sudo scp -r ./build /var/www/html/ecom