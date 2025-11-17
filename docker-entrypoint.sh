#!/bin/sh
set -e

echo "=== Docker Container Starting ==="

# 如果config.json不存在，从example创建
if [ ! -f config.json ]; then
    echo "[Setup] Creating config.json from config.json.example"
    if [ -f config.json.example ]; then
        cp config.json.example config.json
    else
        echo "[Setup] Warning: config.json.example not found, using defaults"
    fi
fi

# Hugging Face Space 使用 PORT 环境变量
if [ -n "$PORT" ]; then
    export SERVER_PORT=$PORT
    echo "[Setup] Using PORT from environment: $PORT"
fi

# 显示配置
echo "[Setup] Configuration:"
echo "  - MODEL_PROVIDER: ${MODEL_PROVIDER:-claude-kiro-oauth}"
echo "  - SERVER_PORT: ${SERVER_PORT:-7860}"
echo "  - HOST: ${HOST:-0.0.0.0}"

# 启动应用
echo "[Setup] Starting API server..."
exec node src/api-server.js "$@"
