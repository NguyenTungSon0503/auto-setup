sudo apt update
sudo apt-get install -y nginx
sudo systemctl status nginx

cd
cd GR2-FE
npm run build
sudo rm -rf /etc/nginx/sites-available/default
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /var/www/html/gr2
sudo scp -r ./build /var/www/html/gr2