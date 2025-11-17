# 环境变量配置指南

## 概述

AIClient2API 支持通过环境变量配置所有关键参数，方便在 Docker、Kubernetes、Hugging Face Space 等容器环境中部署。

## 配置优先级

配置加载顺序（后者覆盖前者）：
1. 默认值
2. `config.json` 文件
3. 命令行参数
4. **环境变量**（最高优先级）

## 支持的环境变量

### 基础配置

#### REQUIRED_API_KEY
- **说明**：API 访问密钥，用于认证 API 请求
- **默认值**：`123456`
- **示例**：`REQUIRED_API_KEY=my-secret-key-2024`
- **用途**：
  ```bash
  curl http://localhost:7860/v1/chat/completions \
    -H "Authorization: Bearer my-secret-key-2024"
  ```

#### SERVER_PORT
- **说明**：服务器监听端口
- **默认值**：`7860`
- **示例**：`SERVER_PORT=8080`

#### HOST
- **说明**：服务器监听地址
- **默认值**：`0.0.0.0`（容器环境）/ `localhost`（本地）
- **示例**：`HOST=0.0.0.0`
- **注意**：Docker 容器必须使用 `0.0.0.0`

#### MODEL_PROVIDER
- **说明**：默认模型提供商
- **默认值**：`claude-kiro-oauth`
- **可选值**：
  - `claude-kiro-oauth` - Kiro Claude
  - `gemini-cli-oauth` - Gemini CLI
  - `openai-custom` - OpenAI
  - `claude-custom` - Claude
  - `openai-qwen-oauth` - Qwen
- **示例**：`MODEL_PROVIDER=gemini-cli-oauth`

#### UI_PASSWORD
- **说明**：Web UI 登录密码
- **默认值**：`123456`
- **示例**：`UI_PASSWORD=MySecurePassword123!`
- **存储位置**：写入 `pwd` 文件

## 使用方法

### 1. Docker 运行时

```bash
docker run -p 7860:7860 \
  -e REQUIRED_API_KEY="my-api-key" \
  -e UI_PASSWORD="my-ui-password" \
  -e MODEL_PROVIDER="claude-kiro-oauth" \
  aiclient2api
```

### 2. Docker Compose

```yaml
version: '3.8'
services:
  aiclient2api:
    image: aiclient2api
    ports:
      - "7860:7860"
    environment:
      - REQUIRED_API_KEY=my-api-key
      - UI_PASSWORD=my-ui-password
      - MODEL_PROVIDER=claude-kiro-oauth
      - SERVER_PORT=7860
      - HOST=0.0.0.0
```

### 3. Hugging Face Space

在 Space Settings → Variables 中添加：

```
REQUIRED_API_KEY=your-secret-key
UI_PASSWORD=your-ui-password
MODEL_PROVIDER=claude-kiro-oauth
```

### 4. Kubernetes

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aiclient2api-config
data:
  REQUIRED_API_KEY: "my-api-key"
  UI_PASSWORD: "my-ui-password"
  MODEL_PROVIDER: "claude-kiro-oauth"
  SERVER_PORT: "7860"
  HOST: "0.0.0.0"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aiclient2api
spec:
  template:
    spec:
      containers:
      - name: aiclient2api
        image: aiclient2api:latest
        envFrom:
        - configMapRef:
            name: aiclient2api-config
```

### 5. 本地开发

#### Linux/macOS
```bash
export REQUIRED_API_KEY="my-api-key"
export UI_PASSWORD="my-ui-password"
node src/api-server.js
```

#### Windows (PowerShell)
```powershell
$env:REQUIRED_API_KEY="my-api-key"
$env:UI_PASSWORD="my-ui-password"
node src/api-server.js
```

#### Windows (CMD)
```cmd
set REQUIRED_API_KEY=my-api-key
set UI_PASSWORD=my-ui-password
node src/api-server.js
```

### 6. .env 文件（需要 dotenv）

创建 `.env` 文件：
```env
REQUIRED_API_KEY=my-api-key
UI_PASSWORD=my-ui-password
MODEL_PROVIDER=claude-kiro-oauth
SERVER_PORT=7860
HOST=0.0.0.0
```

## 验证配置

启动服务后，检查日志：

```
[Config] Loaded configuration from config.json
[Config] REQUIRED_API_KEY overridden from environment variable
[Config] SERVER_PORT overridden from environment variable: 7860
[Config] HOST overridden from environment variable: 0.0.0.0
[Config] MODEL_PROVIDER overridden from environment variable: claude-kiro-oauth
```

## 安全最佳实践

### 1. 使用强密钥
```bash
# 生成随机 API Key
openssl rand -base64 32

# 或使用 UUID
uuidgen
```

### 2. 不要在代码中硬编码
❌ 错误：
```javascript
const API_KEY = "123456";  // 不要这样做！
```

✅ 正确：
```javascript
const API_KEY = process.env.REQUIRED_API_KEY;
```

### 3. 使用密钥管理服务
- AWS Secrets Manager
- Azure Key Vault
- Google Secret Manager
- HashiCorp Vault

### 4. 定期轮换密钥
```bash
# 每月更新一次
REQUIRED_API_KEY=$(openssl rand -base64 32)
```

### 5. 限制访问权限
- 使用防火墙限制 IP
- 启用 HTTPS
- 实施速率限制

## 故障排查

### 问题 1: 环境变量未生效
**症状**：设置了环境变量但仍使用默认值

**解决方案**：
1. 检查环境变量是否正确设置：
   ```bash
   echo $REQUIRED_API_KEY
   ```
2. 确认容器启动时传递了环境变量
3. 查看启动日志确认是否有 "overridden from environment variable" 消息

### 问题 2: API 认证失败
**症状**：API 调用返回 401 Unauthorized

**解决方案**：
1. 确认使用正确的 API Key
2. 检查 Authorization header 格式：
   ```
   Authorization: Bearer YOUR_API_KEY
   ```
3. 查看服务器日志中的认证信息

### 问题 3: Web UI 登录失败
**症状**：输入密码后提示错误

**解决方案**：
1. 检查 `UI_PASSWORD` 环境变量
2. 确认 `pwd` 文件内容
3. 重启服务

## 配置示例

### 开发环境
```bash
REQUIRED_API_KEY=dev-key-123
UI_PASSWORD=dev-password
MODEL_PROVIDER=claude-kiro-oauth
SERVER_PORT=7860
HOST=localhost
```

### 生产环境
```bash
REQUIRED_API_KEY=$(cat /run/secrets/api_key)
UI_PASSWORD=$(cat /run/secrets/ui_password)
MODEL_PROVIDER=claude-kiro-oauth
SERVER_PORT=7860
HOST=0.0.0.0
```

### 测试环境
```bash
REQUIRED_API_KEY=test-key-456
UI_PASSWORD=test-password
MODEL_PROVIDER=gemini-cli-oauth
SERVER_PORT=8080
HOST=0.0.0.0
```

## 相关文档

- [部署指南](DEPLOY_HF.md)
- [密码配置](PASSWORD_CONFIG.md)
- [Kiro 上传指南](KIRO_UPLOAD_GUIDE.md)
- [部署检查清单](DEPLOYMENT_CHECKLIST.md)
