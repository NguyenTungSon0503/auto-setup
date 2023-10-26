#Clone code
cd
git clone -b build https://github.com/NguyenTungSon0503/E-commerce-Admin.git

cd
git clone -b build https://github.com/NguyenTungSon0503/E-commerce-User.git

cd
git clone https://github.com/NguyenTungSon0503/E-commerce-BackEnd.git

#Install node

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
source ~/.nvm/nvm.sh
source ~/.profile
source ~/.bashrc
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm list
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node"
sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm"

#Install Mongodb
sudo apt-get install gnupg curl
curl -fsSL https://pgp.mongodb.com/server-5.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org=5.0.19 mongodb-org-database=5.0.19 mongodb-org-server=5.0.19 mongodb-org-shell=5.0.19 mongodb-org-mongos=5.0.19 mongodb-org-tools=5.0.19
sudo systemctl start mongod
sudo systemctl daemon-reload
sudo systemctl enable mongod

#Install node_modules
cd 
cd E-commerce-BackEnd
npm i 
npm i -g pm2
pm2 status
pm2 delete server
pm2 start --name "server" app.js
cd ../auto-setup
source ./env.sh
sudo env PATH=$PATH:/home/$(whoami)/.nvm/versions/node/v$NODE_VERSION/bin /home/$(whoami)/.nvm/versions/node/v$NODE_VERSION/lib/node_modules/pm2/bin/pm2 startup systemd -u $(whoami) --hp /home/$(whoami)
pm2 save

cd 
cd E-commerce-Admin
npm i 

cd 
cd E-commerce-User
npm i 