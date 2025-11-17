#!/bin/sh
# 配置检查脚本

echo "=== Configuration Check ==="
echo ""

echo "1. Checking config files..."
for file in config.json provider_pools.json kiro-auth-token.json pwd; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists ($(wc -c < "$file") bytes)"
    else
        echo "  ✗ $file NOT FOUND"
    fi
done

echo ""
echo "2. Checking config.json content..."
if [ -f config.json ]; then
    echo "  MODEL_PROVIDER: $(grep -o '"MODEL_PROVIDER": "[^"]*"' config.json | cut -d'"' -f4)"
    echo "  SERVER_PORT: $(grep -o '"SERVER_PORT": [0-9]*' config.json | cut -d':' -f2 | tr -d ' ')"
    echo "  HOST: $(grep -o '"HOST": "[^"]*"' config.json | cut -d'"' -f4)"
    echo "  PROVIDER_POOLS_FILE_PATH: $(grep -o '"PROVIDER_POOLS_FILE_PATH": "[^"]*"' config.json | cut -d'"' -f4)"
fi

echo ""
echo "3. Checking provider_pools.json content..."
if [ -f provider_pools.json ]; then
    cat provider_pools.json | head -n 20
fi

echo ""
echo "4. Checking kiro-auth-token.json..."
if [ -f kiro-auth-token.json ]; then
    echo "  File size: $(wc -c < kiro-auth-token.json) bytes"
    echo "  Has clientId: $(grep -q '"clientId"' kiro-auth-token.json && echo "Yes" || echo "No")"
    echo "  Has accessToken: $(grep -q '"accessToken"' kiro-auth-token.json && echo "Yes" || echo "No")"
fi

echo ""
echo "5. Environment variables..."
echo "  UI_PASSWORD: ${UI_PASSWORD:-not set}"
echo "  MODEL_PROVIDER: ${MODEL_PROVIDER:-not set}"
echo "  SERVER_PORT: ${SERVER_PORT:-not set}"
echo "  HOST: ${HOST:-not set}"

echo ""
echo "=== Check Complete ==="
