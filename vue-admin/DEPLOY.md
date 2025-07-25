
# Vue Admin 部署指南

## 构建生产环境代码

在部署前，首先需要构建生产环境代码：

```bash
# 进入vue-admin目录
cd /path/to/vue-admin

# 安装依赖
npm install

# 构建生产环境代码
npm run build
```

构建完成后，会在项目根目录下生成 `dist` 目录，里面包含了所有静态资源文件。

## 使用Nginx部署

### 1. 将构建好的文件复制到Nginx服务器

将生成的 `dist` 目录中的所有文件复制到Nginx服务器的指定目录，例如：`/usr/share/nginx/html/admin`

### 2. 配置Nginx

我们已经创建了一个完整的Nginx配置文件 `nginx.conf`。在使用此配置前，请根据你的实际情况修改以下内容：

- `server_name`：修改为你的管理后台实际域名
- `/usr/share/nginx/html/admin`：修改为你的静态文件实际存放路径
- `proxy_pass http://47.239.192.234:8090/`：修改为你的实际后端API地址

### 3. 部署Nginx配置

可以使用以下方法之一来应用Nginx配置：

#### 方法一：直接使用配置文件

```bash
# 将配置文件复制到Nginx配置目录
sudo cp nginx.conf /etc/nginx/nginx.conf

# 重启Nginx服务
sudo systemctl restart nginx
```

#### 方法二：配置为站点配置

```bash
# 将配置文件复制到sites-available目录
sudo cp nginx.conf /etc/nginx/sites-available/vue-admin.conf

# 创建软链接到sites-enabled目录
sudo ln -s /etc/nginx/sites-available/vue-admin.conf /etc/nginx/sites-enabled/

# 测试配置文件语法
sudo nginx -t

# 重启Nginx服务
sudo systemctl restart nginx
```

### 4. HTTPS配置（可选）

如果需要启用HTTPS，请取消注释配置文件中的HTTPS部分，并配置SSL证书。
在配置文件中，将以下文件路径替换为你的实际证书路径：

- `ssl_certificate`：指向你的SSL证书文件
- `ssl_certificate_key`：指向你的SSL私钥文件

## 检查部署结果

完成以上步骤后，可以通过访问你配置的域名来检查部署是否成功：

```
http://admin.yourdomain.com
```

或者HTTPS版本：

```
https://admin.yourdomain.com
```

## 常见问题

### 1. API请求出错

检查Nginx配置中的API代理部分是否正确配置，特别是后端API的地址。

### 2. 页面刷新后404错误

确保Nginx配置中包含了正确的前端路由处理：`try_files $uri $uri/ /index.html;`

### 3. 静态资源加载失败

检查Vue应用构建时的publicPath设置是否与实际部署路径一致。
