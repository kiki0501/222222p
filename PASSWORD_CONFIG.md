# Web UI 登录密码配置

## 密码存储位置

Web UI 的登录密码存储在项目根目录的 `pwd` 文件中。

## 配置方法

### 方法 1: 直接修改 pwd 文件

创建或编辑 `pwd` 文件，写入你的密码：

```bash
echo "your_secure_password" > pwd
```

### 方法 2: 通过环境变量（推荐用于 Docker/云部署）

设置 `UI_PASSWORD` 环境变量：

```bash
# Docker 运行时
docker run -p 7860:7860 -e UI_PASSWORD="your_secure_password" aiclient2api

# Docker Compose
environment:
  - UI_PASSWORD=your_secure_password

# Hugging Face Space
# 在 Space 设置中添加环境变量：
# UI_PASSWORD=your_secure_password
```

### 方法 3: 修改 config.json（不推荐）

虽然密码不在 config.json 中，但你可以在启动前创建 pwd 文件。

## 默认密码

如果没有配置密码，系统会使用默认密码：**123456**

⚠️ **安全警告**：在生产环境或公开部署时，请务必修改默认密码！

## 密码要求

- 密码存储为明文（建议使用强密码）
- 密码不能为空
- 建议使用至少 8 位字符，包含字母、数字和特殊字符

## 登录流程

1. 访问 Web UI：`http://your-server:7860/`
2. 系统会自动跳转到登录页面：`http://your-server:7860/login.html`
3. 输入密码登录
4. 登录成功后，token 有效期为 1 小时

## 修改密码后

修改密码后需要：
1. 重启服务（如果是 Docker，重启容器）
2. 重新登录 Web UI

## 示例

### 本地开发
```bash
# 创建密码文件
echo "mypassword123" > pwd

# 启动服务
node src/api-server.js
```

### Docker 部署
```bash
# 构建镜像
docker build -t aiclient2api .

# 运行容器（自定义密码）
docker run -p 7860:7860 \
  -e UI_PASSWORD="MySecurePass123!" \
  aiclient2api
```

### Hugging Face Space
在 Space 的 Settings → Variables 中添加：
- Name: `UI_PASSWORD`
- Value: `your_secure_password`

## 安全建议

1. ✅ 使用强密码（至少 12 位，包含大小写字母、数字、特殊字符）
2. ✅ 定期更换密码
3. ✅ 不要在代码仓库中提交 `pwd` 文件（已在 .gitignore 中）
4. ✅ 使用环境变量而不是硬编码密码
5. ✅ 在公开部署时启用 HTTPS
