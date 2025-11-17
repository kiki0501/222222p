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

# 检查provider_pools.json
if [ ! -f provider_pools.json ]; then
    echo "[Setup] Warning: provider_pools.json not found, creating empty file"
    echo '{}' > provider_pools.json
else
    echo "[Setup] Found provider_pools.json"
    # 显示文件大小和内容预览
    ls -lh provider_pools.json
    echo "[Setup] Content preview:"
    head -n 5 provider_pools.json
fi

# 设置登录密码（从环境变量或使用默认值）
if [ -n "$UI_PASSWORD" ]; then
    echo "[Setup] Setting UI login password from environment variable"
    echo "$UI_PASSWORD" > pwd
elif [ ! -f pwd ]; then
    echo "[Setup] Creating default password file (pwd)"
    echo "123456" > pwd
fi

# Hugging Face Space 使用 PORT 环境变量
if [ -n "$PORT" ]; then
    export SERVER_PORT=$PORT
    echo "[Setup] Using PORT from environment: $PORT"
fi

# 使用 sed 更新 config.json 中的 HOST 为 0.0.0.0（容器环境必须）
if [ -f config.json ]; then
    echo "[Setup] Updating HOST to 0.0.0.0 in config.json"
    sed -i 's/"HOST": "127.0.0.1"/"HOST": "0.0.0.0"/g' config.json
    
    # 如果设置了 PORT 环境变量，也更新配置文件
    if [ -n "$SERVER_PORT" ]; then
        echo "[Setup] Updating SERVER_PORT to $SERVER_PORT in config.json"
        sed -i "s/\"SERVER_PORT\": [0-9]*/\"SERVER_PORT\": $SERVER_PORT/g" config.json
    fi
fi

# 显示配置
echo "[Setup] Configuration:"
echo "  - MODEL_PROVIDER: ${MODEL_PROVIDER:-claude-kiro-oauth}"
echo "  - SERVER_PORT: ${SERVER_PORT:-7860}"
echo "  - HOST: 0.0.0.0"

# 启动应用
echo "[Setup] Starting API server..."
exec node src/api-server.js --host 0.0.0.0 --port ${SERVER_PORT:-7860} "$@"
