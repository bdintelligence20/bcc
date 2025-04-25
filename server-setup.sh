#!/bin/bash
echo "Setting up BAIC Global Codebase on server..."
echo

echo "Step 1: Creating necessary directories..."
sudo mkdir -p /opt/baic/{uploads,logs}
sudo mkdir -p /opt/baic/apps/{frontend,admin,backend-admin,backend-web,geoip}
sudo chown -R ubuntu:ubuntu /opt/baic
sudo chmod -R 755 /opt/baic
echo

echo "Step 2: Setting up backend services..."
cp -r beiqi-service-master/beiqi-service-master/ruoyi-admin/target/ruoyi-admin.jar /opt/baic/apps/backend-admin/
cp -r beiqi-service-master/beiqi-service-master/ruoyi-web/target/ruoyi-web.jar /opt/baic/apps/backend-web/
echo

echo "Step 3: Setting up frontend application..."
cp -r beiqi-home-master/beiqi-home-master/package.json /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/nuxt.config.js /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/.nuxt /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/static /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/plugins /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/assets /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/components /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/layouts /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/middleware /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/pages /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/store /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/utils /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/locales /opt/baic/apps/frontend/
cp -r beiqi-home-master/beiqi-home-master/constants /opt/baic/apps/frontend/
echo

echo "Step 4: Setting up admin panel..."
cp -r beiqi-web-master/beiqi-web-master/dist/* /opt/baic/apps/admin/
echo

echo "Step 5: Setting up GeoIP service..."
cp -r beiqi-geoip/beiqi-geoip/* /opt/baic/apps/geoip/
echo

echo "Step 6: Creating service files..."
sudo tee /etc/systemd/system/baic-admin.service > /dev/null << 'EOF'
[Unit]
Description=BAIC Admin Backend Service
After=syslog.target network.target mysql.service

[Service]
User=ubuntu
WorkingDirectory=/opt/baic/apps/backend-admin
ExecStart=/usr/bin/java -jar -Dspring.profiles.active=prod /opt/baic/apps/backend-admin/ruoyi-admin.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/baic-web.service > /dev/null << 'EOF'
[Unit]
Description=BAIC Web Backend Service
After=syslog.target network.target mysql.service

[Service]
User=ubuntu
WorkingDirectory=/opt/baic/apps/backend-web
ExecStart=/usr/bin/java -jar -Dspring.profiles.active=prod /opt/baic/apps/backend-web/ruoyi-web.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/baic-frontend.service > /dev/null << 'EOF'
[Unit]
Description=BAIC Frontend Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/baic/apps/frontend
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/baic-geoip.service > /dev/null << 'EOF'
[Unit]
Description=BAIC GeoIP Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/baic/apps/geoip
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Step 7: Creating Nginx configuration..."
sudo tee /etc/nginx/sites-available/baic > /dev/null << 'EOF'
server {
    listen 80;
    server_name 154.65.100.153;

    # Main website (Nuxt.js)
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Admin panel (static files)
    location /admin/ {
        alias /opt/baic/apps/admin/;
        try_files $uri $uri/ /admin/index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:7070;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Home API
    location /home-api/ {
        proxy_pass http://localhost:7071;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # GeoIP service
    location /geoip/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # File uploads
    location /file/ {
        alias /opt/baic/uploads/;
        autoindex off;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/baic /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

echo "Step 8: Installing dependencies and starting services..."
cd /opt/baic/apps/frontend
npm install --production
cd /opt/baic/apps/geoip
npm install --production
cd ~
sudo systemctl daemon-reload
sudo systemctl enable baic-admin baic-web baic-frontend baic-geoip
sudo systemctl start baic-admin baic-web baic-frontend baic-geoip

echo
echo "Setup complete! The application should now be accessible at http://154.65.100.153"
