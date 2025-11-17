# Kiro 凭据上传功能使用指南

## 功能说明

在 Web UI 中直接上传 Kiro 认证凭据文件（`kiro-auth-token.json`），自动添加到提供商号池中，无需手动编辑配置文件。

## 使用步骤

### 1. 获取 Kiro 凭据文件

从 Kiro IDE 客户端导出认证凭据：
- 文件名：`kiro-auth-token.json`
- 位置：通常在 `~/.kiro/` 或 `~/.aws/sso/cache/` 目录

### 2. 登录 Web UI

访问：`http://your-server:7860/`
- 默认密码：`123456`（建议修改）

### 3. 上传凭据

1. 点击左侧导航栏的 **"提供商池管理"**
2. 点击右上角的 **"上传 Kiro 凭据"** 按钮
3. 在弹出的对话框中：
   - 拖拽 `kiro-auth-token.json` 文件到上传区域
   - 或点击 **"选择文件"** 按钮浏览文件
4. （可选）输入账号名称，例如：`kiro-account-1`
5. 点击 **"上传并添加到号池"**

### 4. 验证上传

上传成功后：
- 系统会自动验证文件格式
- 将凭据添加到 `provider_pools.json`
- 在提供商池列表中显示新账号
- 自动刷新配置

## 文件格式要求

`kiro-auth-token.json` 必须包含以下字段：

```json
{
  "clientId": "...",
  "clientSecret": "...",
  "accessToken": "...",
  "refreshToken": "...",
  "profileArn": "...",
  "expiresAt": "...",
  "authMethod": "social",
  "provider": "Google"
}
```

## 自动验证

系统会自动检查：
- ✅ 文件格式是否为 JSON
- ✅ 文件大小（最大 1MB）
- ✅ 必需字段是否完整
- ✅ 是否有重复字段（如 `expiresAt`）

## 上传后的文件位置

- 凭据文件保存在：`configs/claude-kiro-oauth/` 目录
- 号池配置更新在：`provider_pools.json`

## 管理已上传的凭据

### 查看凭据
1. 进入 **"提供商池管理"**
2. 找到 `claude-kiro-oauth` 提供商
3. 查看账号列表和状态

### 删除凭据
1. 进入 **"上传配置管理"**
2. 找到对应的凭据文件
3. 点击删除按钮

### 更新凭据
1. 删除旧凭据
2. 重新上传新凭据

## 故障排查

### 上传失败
**问题**：提示"上传失败"

**解决方案**：
1. 检查文件格式是否正确
2. 确认文件包含所有必需字段
3. 检查文件大小是否超过 1MB
4. 查看浏览器控制台错误信息

### 文件验证失败
**问题**：提示"文件格式错误"

**解决方案**：
1. 使用 JSON 验证工具检查文件格式
2. 确认没有重复的字段
3. 检查 JSON 语法是否正确

### 号池未更新
**问题**：上传成功但号池中看不到

**解决方案**：
1. 刷新页面
2. 检查 `provider_pools.json` 文件
3. 查看服务器日志

## API 接口

如果需要通过 API 上传：

```bash
curl -X POST http://localhost:7860/api/upload-oauth-credentials \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@kiro-auth-token.json" \
  -F "provider=claude-kiro-oauth" \
  -F "accountName=kiro-account-1"
```

## 安全建议

1. ✅ 定期更新凭据
2. ✅ 使用强密码保护 Web UI
3. ✅ 不要在公开环境中暴露凭据文件
4. ✅ 启用 HTTPS（生产环境）
5. ✅ 定期检查账号健康状态

## 相关文档

- [密码配置指南](PASSWORD_CONFIG.md)
- [Hugging Face 部署指南](DEPLOY_HF.md)
- [提供商池配置示例](provider_pools.json.example)
