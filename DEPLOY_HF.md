# Hugging Face Space 部署指南

## 快速部署步骤

### 1. 准备文件
确保以下文件存在于项目根目录：
- `config.json` 或 `config.json.example`
- `kiro-auth-token.json` (你的 Kiro 认证凭据)
- `provider_pools.json` (账号池配置)
- `Dockerfile`
- `docker-entrypoint.sh`

### 2. 创建 Hugging Face Space
1. 访问 https://huggingface.co/new-space
2. 选择 **Docker** 作为 Space SDK
3. 设置为 **Public** 或 **Private**

### 3. 配置 Space
在 Space 设置中添加以下环境变量（可选）：

```bash
MODEL_PROVIDER=claude-kiro-oauth
SERVER_PORT=7860
HOST=0.0.0.0
UI_PASSWORD=your_secure_password  # Web UI 登录密码，默认为 123456
```

**重要提示**：强烈建议修改默认密码 `UI_PASSWORD`，特别是在公开部署时！

### 4. 上传文件
将以下文件推送到 Space 仓库：
```bash
git clone https://huggingface.co/spaces/YOUR_USERNAME/YOUR_SPACE_NAME
cd YOUR_SPACE_NAME

# 复制项目文件
cp -r /path/to/your/project/* .

# 提交并推送
git add .
git commit -m "Initial deployment"
git push
```

### 5. 访问服务
部署完成后，访问：
- UI 管理界面: `https://YOUR_USERNAME-YOUR_SPACE_NAME.hf.space/`
- API 端点: `https://YOUR_USERNAME-YOUR_SPACE_NAME.hf.space/claude-kiro-oauth/v1/chat/completions`

## 环境变量说明

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `PORT` | 7860 | HF Space 自动设置，无需手动配置 |
| `MODEL_PROVIDER` | claude-kiro-oauth | 模型提供商 |
| `HOST` | 0.0.0.0 | 监听地址 |
| `UI_PASSWORD` | 123456 | Web UI 登录密码 |
| `SPACE_ID` | docker | 容器标识（自动设置） |

## 故障排查

### 问题：一直显示 "Restarting"
**原因**: 容器启动失败或配置文件缺失

**解决方案**:
1. 检查 Space 日志查看错误信息
2. 确保 `config.json.example` 文件存在
3. 确保 `kiro-auth-token.json` 格式正确（无重复字段）

### 问题：找不到 config.json
**原因**: Docker 构建时文件未复制

**解决方案**:
- 启动脚本会自动从 `config.json.example` 创建
- 或者在构建前确保 `config.json` 存在

### 问题：端口不匹配
**原因**: HF Space 使用动态端口

**解决方案**:
- 使用 `PORT` 环境变量（自动处理）
- 或在 Dockerfile 中设置 `EXPOSE 7860`

## 测试 API

```bash
# 测试健康检查
curl https://YOUR_SPACE.hf.space/health

# 测试 API 调用
curl https://YOUR_SPACE.hf.space/claude-kiro-oauth/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 123456" \
  -d '{
    "model": "claude-sonnet-4",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```
