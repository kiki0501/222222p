# 使用官方Node.js运行时作为基础镜像
# 选择20-alpine版本以满足undici包的要求（需要Node.js >=20.18.1）
FROM node:20-alpine

# 设置标签
LABEL maintainer="AIClient2API Team"
LABEL description="Docker image for AIClient2API server"

# 设置工作目录
WORKDIR /app

# 复制package.json和package-lock.json（如果存在）
COPY package*.json ./

# 安装依赖
# 使用--production标志只安装生产依赖，减小镜像大小
# 使用--omit=dev来排除开发依赖
RUN npm install 

# 复制源代码
COPY . .

USER root

# 创建目录用于存储日志和系统提示文件
RUN mkdir -p /app/logs

# 确保配置文件存在
RUN if [ ! -f config.json ] && [ -f config.json.example ]; then \
        echo "[Build] Creating config.json from example"; \
        cp config.json.example config.json; \
    fi && \
    echo "[Build] Checking configuration files..." && \
    if [ -f provider_pools.json ]; then \
        echo "[Build] Found provider_pools.json ($(wc -c < provider_pools.json) bytes)"; \
        ls -lh provider_pools.json; \
    else \
        echo "[Build] provider_pools.json not found (will be created at runtime if needed)"; \
    fi && \
    if [ -f kiro-auth-token.json ]; then \
        echo "[Build] Found kiro-auth-token.json ($(wc -c < kiro-auth-token.json) bytes)"; \
        ls -lh kiro-auth-token.json; \
    else \
        echo "[Build] kiro-auth-token.json not found"; \
    fi

# 复制启动脚本
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# 暴露端口
EXPOSE 7860

# 设置环境变量
ENV SPACE_ID=docker \
    SERVER_PORT=7860 \
    HOST=0.0.0.0 \
    MODEL_PROVIDER=claude-kiro-oauth \
    REQUIRED_API_KEY=123456 \
    UI_PASSWORD=123456

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# 设置启动脚本为入口点
ENTRYPOINT ["/app/docker-entrypoint.sh"]