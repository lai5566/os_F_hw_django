#!/bin/bash

# 檢查是否以 root 用戶運行
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# 請求用戶輸入網站域名、主機 IP 和網站端口
read -p "Enter the domain name: " DOMAIN_NAME
read -p "Enter the host IP address: " HOST_IP
read -p "Enter the website port: " WEBSITE_PORT

# 安裝 BIND9 和 Nginx
apt update
apt install -y bind9 bind9utils bind9-doc nginx

# 設置區域名
REVERSE_ZONE="0.168.192.in-addr.arpa"

# 設置配置文件路徑
NAMED_CONF_LOCAL="/etc/bind/named.conf.local"
NAMED_CONF_OPTIONS="/etc/bind/named.conf.options"
FORWARD_ZONE_FILE="/etc/bind/db.${DOMAIN_NAME}"
REVERSE_ZONE_FILE="/etc/bind/db.192.168.0"

# 編輯 named.conf.local
cat <<EOL > $NAMED_CONF_LOCAL
zone "${DOMAIN_NAME}" {
    type master;
    file "${FORWARD_ZONE_FILE}";
};

zone "${REVERSE_ZONE}" {
    type master;
    file "${REVERSE_ZONE_FILE}";
};
EOL

# 編輯 named.conf.options
cat <<EOL > $NAMED_CONF_OPTIONS
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-recursion { any; };

    forwarders {
        8.8.8.8;  // Google Public DNS
        8.8.4.4;  // Google Public DNS
    };

    dnssec-validation auto;

    auth-nxdomain no;    # conform to RFC1035
    listen-on { any; };
};
EOL

# 創建正向區域文件
cat <<EOL > $FORWARD_ZONE_FILE
\$TTL    604800
@       IN      SOA     ns1.${DOMAIN_NAME}. admin.${DOMAIN_NAME}. (
                      2024060101         ; Serial
                      604800             ; Refresh
                      86400              ; Retry
                      2419200            ; Expire
                      604800 )           ; Negative Cache TTL
;
@       IN      NS      ns1.${DOMAIN_NAME}.
@       IN      A       ${HOST_IP}
ns1     IN      A       ${HOST_IP}
www     IN      A       ${HOST_IP}
EOL

# 創建反向區域文件
cat <<EOL > $REVERSE_ZONE_FILE
\$TTL    604800
@       IN      SOA     ns1.${DOMAIN_NAME}. admin.${DOMAIN_NAME}. (
                      2024060101         ; Serial
                      604800             ; Refresh
                      86400              ; Retry
                      2419200            ; Expire
                      604800 )           ; Negative Cache TTL
;
@       IN      NS      ns1.${DOMAIN_NAME}.
1       IN      PTR     ns1.${DOMAIN_NAME}.
2       IN      PTR     www.${DOMAIN_NAME}.
EOL

# 測試 BIND9 配置
named-checkconf
named-checkzone ${DOMAIN_NAME} ${FORWARD_ZONE_FILE}
named-checkzone ${REVERSE_ZONE} ${REVERSE_ZONE_FILE}

# 重啟 BIND9 服務
systemctl restart bind9

# 配置 Nginx
NGINX_CONF="/etc/nginx/sites-available/${DOMAIN_NAME}"
cat <<EOL > $NGINX_CONF
server {
    listen 80;
    server_name ${DOMAIN_NAME};

    location / {
        proxy_pass http://127.0.0.1:${WEBSITE_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# 創建符號鏈接以啟用 Nginx 配置
ln -s /etc/nginx/sites-available/${DOMAIN_NAME} /etc/nginx/sites-enabled/

# 測試 Nginx 配置並重新加載
nginx -t
systemctl reload nginx

# 修改本地 hosts 文件
echo "${HOST_IP}    ${DOMAIN_NAME}" >> /etc/hosts

echo "BIND9 and Nginx have been configured successfully for ${DOMAIN_NAME} with IP ${HOST_IP} and port ${WEBSITE_PORT}."
echo "Please make sure to update your local hosts file to include the following line if you haven't done so already:"
echo "${HOST_IP}    ${DOMAIN_NAME}"

