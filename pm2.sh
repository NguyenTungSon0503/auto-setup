cd
cd E-commerce-BackEnd
pm2 delete server
pm2 start --name "server" app.js
sudo env PATH=$PATH:/home/$(whoami)/.nvm/versions/node/v$NODE_VERSION/bin /home/$(whoami)/.nvm/versions/node/v$NODE_VERSION/lib/node_modules/pm2/bin/pm2 startup systemd -u $(whoami) --hp /home/$(whoami)
pm2 save