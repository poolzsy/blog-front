#!/bin/bash
# Vue Admin 部署脚本

# 颜色定义
GREEN="[0;32m"
YELLOW="[1;33m"
RED="[0;31m"
NC="[0m" # No Color

echo -e "${YELLOW}=== Vue Admin 部署脚本 ===${NC}"
echo -e "${YELLOW}该脚本将帮助您构建并部署Vue Admin应用${NC}"
echo ""

# 检查是否安装了必要的工具
command -v npm >/dev/null 2>&1 || { echo -e "${RED}错误: 需要npm但未安装。请先安装Node.js和npm。${NC}"; exit 1; }
command -v nginx >/dev/null 2>&1 || { echo -e "${YELLOW}警告: 未检测到nginx。脚本将继续运行，但您需要手动配置Nginx。${NC}"; }

# 构建项目
echo -e "${GREEN}开始构建项目...${NC}"
npm install || { echo -e "${RED}依赖安装失败！${NC}"; exit 1; }
npm run build || { echo -e "${RED}构建失败！${NC}"; exit 1; }
echo -e "${GREEN}项目构建完成！${NC}"

# 询问部署路径
read -p "请输入Nginx静态文件部署路径 (默认: /usr/share/nginx/html/admin): " deploy_path
deploy_path=${deploy_path:-/usr/share/nginx/html/admin}

# 询问后端API地址
read -p "请输入后端API地址 (默认: http://47.239.192.234:8090): " api_url
api_url=${api_url:-http://47.239.192.234:8090}

# 询问域名
read -p "请输入管理后台域名 (默认: admin.yourdomain.com): " domain
domain=${domain:-admin.yourdomain.com}

echo ""
echo -e "${YELLOW}即将进行以下部署操作:${NC}"
echo -e "- 部署静态文件到: ${GREEN}${deploy_path}${NC}"
echo -e "- 后端API地址: ${GREEN}${api_url}${NC}"
echo -e "- 管理后台域名: ${GREEN}${domain}${NC}"
echo ""

# 确认部署
read -p "是否继续部署? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo -e "${YELLOW}部署已取消${NC}"
    exit 0
fi

# 创建部署目录
echo -e "${GREEN}创建部署目录...${NC}"
sudo mkdir -p $deploy_path || { echo -e "${RED}创建目录失败！${NC}"; exit 1; }

# 复制文件
echo -e "${GREEN}复制静态文件...${NC}"
sudo cp -r dist/* $deploy_path || { echo -e "${RED}复制文件失败！${NC}"; exit 1; }

# 修改Nginx配置
echo -e "${GREEN}配置Nginx...${NC}"

# 生成临时配置文件
tmp_config=$(mktemp)
cat nginx.conf | sed "s|server_name  admin.yourdomain.com|server_name  $domain|g" |                  sed "s|root   /usr/share/nginx/html/admin|root   $deploy_path|g" |                  sed "s|proxy_pass http://47.239.192.234:8090/|proxy_pass $api_url/|g" > $tmp_config

# 询问是否使用HTTPS
read -p "是否配置HTTPS? (y/n): " use_https
if [[ $use_https == "y" || $use_https == "Y" ]]; then
    read -p "请输入SSL证书路径: " ssl_cert
    read -p "请输入SSL私钥路径: " ssl_key

    # 取消注释HTTPS部分并更新证书路径
    sed -i "s|# server {|server {|g" $tmp_config
    sed -i "s|#     listen       443 ssl;|    listen       443 ssl;|g" $tmp_config
    sed -i "s|#     server_name  admin.yourdomain.com;|    server_name  $domain;|g" $tmp_config
    sed -i "s|#     ssl_certificate      /path/to/your/certificate.crt;|    ssl_certificate      $ssl_cert;|g" $tmp_config
    sed -i "s|#     ssl_certificate_key  /path/to/your/private.key;|    ssl_certificate_key  $ssl_key;|g" $tmp_config
    sed -i "s|#     ssl_session_cache    shared:SSL:1m;|    ssl_session_cache    shared:SSL:1m;|g" $tmp_config
    sed -i "s|#     ssl_session_timeout  5m;|    ssl_session_timeout  5m;|g" $tmp_config
    sed -i "s|#     ssl_ciphers  HIGH:!aNULL:!MD5;|    ssl_ciphers  HIGH:!aNULL:!MD5;|g" $tmp_config
    sed -i "s|#     ssl_prefer_server_ciphers  on;|    ssl_prefer_server_ciphers  on;|g" $tmp_config
    sed -i "s|#     location / {|    location / {|g" $tmp_config
    sed -i "s|#         root   /usr/share/nginx/html/admin;|        root   $deploy_path;|g" $tmp_config
    sed -i "s|#         try_files \$uri \$uri/ /index.html;|        try_files \$uri \$uri/ /index.html;|g" $tmp_config
    sed -i "s|#         index  index.html index.htm;|        index  index.html index.htm;|g" $tmp_config
    sed -i "s|#     }|    }|g" $tmp_config
    sed -i "s|#     location /prod-api/ {|    location /prod-api/ {|g" $tmp_config
    sed -i "s|#         proxy_pass http://47.239.192.234:8090/;|        proxy_pass $api_url/;|g" $tmp_config
    sed -i "s|#         proxy_set_header Host \$host;|        proxy_set_header Host \$host;|g" $tmp_config
    sed -i "s|#         proxy_set_header X-Real-IP \$remote_addr;|        proxy_set_header X-Real-IP \$remote_addr;|g" $tmp_config
    sed -i "s|#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;|        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;|g" $tmp_config
    sed -i "s|#     }|    }|g" $tmp_config
    sed -i "s|# }|}|g" $tmp_config
fi

# 询问配置Nginx的方式
echo -e "${YELLOW}如何应用Nginx配置?${NC}"
echo "1) 直接替换主配置文件 (/etc/nginx/nginx.conf)"
echo "2) 创建站点配置文件 (/etc/nginx/sites-available/)"
read -p "请选择 (1/2): " nginx_config_method

if [ "$nginx_config_method" == "1" ]; then
    # 备份原配置
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d%H%M%S)
    # 应用新配置
    sudo cp $tmp_config /etc/nginx/nginx.conf
    echo -e "${GREEN}已将配置应用到 /etc/nginx/nginx.conf${NC}"
else
    # 创建站点配置
    sudo cp $tmp_config /etc/nginx/sites-available/vue-admin.conf
    # 创建软链接
    sudo ln -sf /etc/nginx/sites-available/vue-admin.conf /etc/nginx/sites-enabled/
    echo -e "${GREEN}已将配置应用到 /etc/nginx/sites-available/vue-admin.conf${NC}"
fi

# 删除临时文件
rm $tmp_config

# 测试Nginx配置
echo -e "${GREEN}测试Nginx配置...${NC}"
sudo nginx -t
if [ $? -ne 0 ]; then
    echo -e "${RED}Nginx配置测试失败！请检查配置文件并手动修复。${NC}"
    exit 1
fi

# 重启Nginx
echo -e "${GREEN}重启Nginx...${NC}"
sudo systemctl restart nginx || { echo -e "${RED}重启Nginx失败！${NC}"; exit 1; }

echo ""
echo -e "${GREEN}=== 部署完成! ===${NC}"
echo -e "您的Vue Admin应用已部署到: ${YELLOW}http://$domain${NC}"
if [[ $use_https == "y" || $use_https == "Y" ]]; then
    echo -e "HTTPS访问地址: ${YELLOW}https://$domain${NC}"
fi
echo ""
echo -e "${YELLOW}如果遇到任何问题，请查阅 DEPLOY.md 获取更多信息。${NC}"
