#!/bin/bash
# Killercoda 環境驗證腳本
# 用途：快速檢查環境是否符合 Ansible Demo 的執行需求

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  Killercoda 環境檢查腳本"
echo "========================================="
echo ""

# 1. 檢查 Ansible
echo -n "檢查 Ansible 安裝狀態... "
if command -v ansible &> /dev/null; then
    VERSION=$(ansible --version | head -n 1)
    echo -e "${GREEN}✓${NC} $VERSION"
else
    echo -e "${RED}✗ 未安裝${NC}"
    echo "   請執行: apt update && apt install ansible -y"
    exit 1
fi

# 2. 檢查 SSH 連線
echo -n "檢查 SSH 連線到 node01... "
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 node01 "exit" &> /dev/null; then
    echo -e "${GREEN}✓ 可連線${NC}"
else
    echo -e "${RED}✗ 無法連線${NC}"
    echo "   請執行: ssh-keygen && ssh-copy-id node01"
    exit 1
fi

# 3. 檢查檔案結構
echo -n "檢查 demo 目錄結構... "
REQUIRED_FILES=(
    "inventory/hosts"
    "templates/index.html.j2"
    "templates/nginx.conf.j2"
    "tasks/web_server_setup.yml"
    "deploy.sh"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        if [ $MISSING -eq 0 ]; then
            echo -e "${RED}✗ 缺少檔案${NC}"
        fi
        echo "   - $file"
        MISSING=1
    fi
done

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✓ 完整${NC}"
else
    exit 1
fi

# 4. 檢查 Ansible Inventory
echo -n "檢查 Inventory 配置... "
if ansible -i inventory/hosts all --list-hosts &> /dev/null; then
    HOST_COUNT=$(ansible -i inventory/hosts all --list-hosts | grep -c "node01")
    echo -e "${GREEN}✓ 找到 $HOST_COUNT 個主機${NC}"
else
    echo -e "${RED}✗ Inventory 配置錯誤${NC}"
    exit 1
fi

# 5. 測試 Ansible ping
echo -n "測試 Ansible ping 模組... "
if ansible -i inventory/hosts all -m ping &> /dev/null; then
    echo -e "${GREEN}✓ 通過${NC}"
else
    echo -e "${RED}✗ 失敗${NC}"
    echo "   提示: 確認 SSH 免密碼登入已設定"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  ✓ 所有檢查通過！${NC}"
echo -e "${GREEN}  可以執行: ./deploy.sh${NC}"
echo -e "${GREEN}=========================================${NC}"
