bashCopy code
#!/bin/bash

# 檢查是否以 root 用戶運行
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# 請求用戶輸入主機 IP
read -p "Enter the host IP address: " HOST_IP

# 安裝 BIND9
apt update
apt install -y bind9 bind9utils bind9-doc

# 設置區域名
ZONE="healthcareforms.com"
REVERSE_ZONE="0.168.192.in-addr.arpa"

# 設置配置文件路徑
NAMED_CONF="/etc/bind/named.conf"
NAMED_CONF_LOCAL="/etc/bind/named.conf.local"
NAMED_CONF_OPTIONS="/etc/bind/named.conf.options"
FORWARD_ZONE_FILE="/etc/bind/db.${ZONE}"
REVERSE_ZONE_FILE="/etc/bind/db.192.168.0"

# 編輯 named.conf.local
cat <<EOL > $NAMED_CONF_LOCAL
zone "${ZONE}" {
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
@       IN      SOA     ns1.${ZONE}. admin.${ZONE}. (
                      2024060101         ; Serial
                      604800             ; Refresh
                      86400              ; Retry
                      2419200            ; Expire
                      604800 )           ; Negative Cache TTL
;
@       IN      NS      ns1.${ZONE}.
@       IN      A       ${HOST_IP}
ns1     IN      A       ${HOST_IP}
www     IN      A       ${HOST_IP}
EOL

# 創建反向區域文件
cat <<EOL > $REVERSE_ZONE_FILE
\$TTL    604800
@       IN      SOA     ns1.${ZONE}. admin.${ZONE}. (
                      2024060101         ; Serial
                      604800             ; Refresh
                      86400              ; Retry
                      2419200            ; Expire
                      604800 )           ; Negative Cache TTL
;
@       IN      NS      ns1.${ZONE}.
1       IN      PTR     ns1.${ZONE}.
2       IN      PTR     www.${ZONE}.
EOL

# 測試配置
named-checkconf
named-checkzone ${ZONE} ${FORWARD_ZONE_FILE}
named-checkzone ${REVERSE_ZONE} ${REVERSE_ZONE_FILE}

# 重啟 BIND9 服務
systemctl restart bind9

# 檢查服務狀態
systemctl status bind9

echo "BIND9 DNS server configured successfully with IP ${HOST_IP} for zone ${ZONE}"

