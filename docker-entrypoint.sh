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
    FILE_SIZE=$(wc -c < provider_pools.json)
    ls -lh provider_pools.json
    
    # 如果文件太小（小于10字节），可能是空文件，不要覆盖
    if [ "$FILE_SIZE" -lt 10 ]; then
        echo "[Setup] Warning: provider_pools.json is too small ($FILE_SIZE bytes), might be empty"
    else
        echo "[Setup] Content preview:"
        head -n 10 provider_pools.json
    fi
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

# 使用 sed 更新 config.json 中的配置（容器环境必须）
if [ -f config.json ]; then
    echo "[Setup] Updating config.json for container environment"
    
    # 更新 HOST 为 0.0.0.0
    sed -i 's/"HOST": "127.0.0.1"/"HOST": "0.0.0.0"/g' config.json
    
    # 如果设置了 SERVER_PORT 环境变量，更新端口
    if [ -n "$SERVER_PORT" ]; then
        echo "[Setup] Updating SERVER_PORT to $SERVER_PORT"
        sed -i "s/\"SERVER_PORT\": [0-9]*/\"SERVER_PORT\": $SERVER_PORT/g" config.json
    fi
    
    # 如果设置了 REQUIRED_API_KEY 环境变量，更新 API Key
    if [ -n "$REQUIRED_API_KEY" ]; then
        echo "[Setup] Updating REQUIRED_API_KEY from environment variable"
        sed -i "s/\"REQUIRED_API_KEY\": \"[^\"]*\"/\"REQUIRED_API_KEY\": \"$REQUIRED_API_KEY\"/g" config.json
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
