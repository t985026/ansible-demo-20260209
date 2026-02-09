#!/bin/bash

set -e  # 遇到錯誤立即停止

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==========================================
# 函數定義
# ==========================================

print_banner() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Ansible Automation Deployer${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_prerequisites() {
    print_info "檢查前置需求..."
    
    # 檢查 Ansible 是否已安裝
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible 未安裝！"
        echo "請執行以下指令安裝 Ansible:"
        echo "  Ubuntu/Debian: sudo apt install ansible -y"
        echo "  RHEL/CentOS:   sudo yum install ansible -y"
        exit 1
    fi
    
    # 檢查 Ansible 版本
    ansible_version=$(ansible --version | head -n 1)
    print_success "Ansible 已安裝: $ansible_version"
    
    # 檢查 inventory 檔案是否存在
    if [ ! -f "inventory/hosts" ]; then
        print_error "找不到 inventory/hosts 檔案！"
        exit 1
    fi
    
    print_success "前置檢查完成"
}

show_inventory() {
    print_info "主機清單內容："
    cat inventory/hosts
}

ping_test() {
    print_info "測試 Ansible 連線..."
    ansible -i inventory/hosts all -m ping
}

run_web_server_setup() {
    print_info "執行 Web Server 部署..."
    ansible-playbook -i inventory/hosts tasks/web_server_setup.yml
    print_success "Web Server 部署完成"
}

# ==========================================
# 主程式
# ==========================================

print_banner
check_prerequisites
show_inventory
ping_test
run_web_server_setup
