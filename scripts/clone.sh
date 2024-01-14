#Clone code
# cd
# git clone -b production https://github.com/NguyenTungSon0503/GR2-FE.git

# cd
# git clone https://github.com/NguyenTungSon0503/GR2-BE.git

# #Install node

# export NODE_VERSION=18.16.0
# curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
# source ~/.nvm/nvm.sh
# source ~/.profile
# source ~/.bashrc
# nvm install $NODE_VERSION
# nvm use $NODE_VERSION
# nvm list
# sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node"
# sudo ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm"

#Install node_modules
cd 
cd GR2-BE
npm i 
npm i -g pm2
pm2 status
pm2 delete server
mkdir uploads
pm2 start --name "server" src/index.js
sudo env PATH=$PATH:/home/$(whoami)/.nvm/versions/node/v$NODE_VERSION/bin /home/$(whoami)/.nvm/versions/node/v$NODE_VERSION/lib/node_modules/pm2/bin/pm2 startup systemd -u $(whoami) --hp /home/$(whoami)
pm2 save

cd 
cd GR2-FE
npm i 