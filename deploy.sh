#!/bin/bash
# ==========================================
# Ansible 自動化部署腳本
# 用途：簡化 Ansible Playbook 執行流程
# ==========================================

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
    if [ ! -f "inventory/staging" ]; then
        print_error "找不到 inventory/staging 檔案！"
        exit 1
    fi
    
    print_success "前置檢查完成"
}

run_preflight_check() {
    print_info "執行前置系統檢查..."
    ansible-playbook -i inventory/staging preflight_check.yml
    print_success "前置檢查通過"
}

run_base_setup() {
    print_info "執行基礎環境建置..."
    ansible-playbook -i inventory/staging base_system_setup.yml
    print_success "基礎環境建置完成"
}

run_system_hardening() {
    print_info "執行系統安全加固..."
    ansible-playbook -i inventory/staging system_hardening.yml
    print_success "系統加固完成"
}

run_web_server_setup() {
    print_info "執行 Web Server 部署..."
    ansible-playbook -i inventory/staging web_server_setup.yml
    print_success "Web Server 部署完成"
}

run_complete_bootstrap() {
    print_info "執行完整系統部署..."
    ansible-playbook -i inventory/staging complete_bootstrap.yml
    print_success "完整部署完成"
}

run_connectivity_check() {
    print_info "執行連線測試..."
    ansible-playbook -i inventory/staging tools/connectivity_check.yml
    print_success "連線測試完成"
}

show_menu() {
    echo ""
    echo "請選擇執行項目："
    echo "  1) 前置系統檢查 (Preflight Check)"
    echo "  2) 基礎環境建置 (Base System Setup)"
    echo "  3) 系統安全加固 (System Hardening)"
    echo "  4) Web Server 部署 (Nginx Setup)"
    echo "  5) 完整系統部署 (All-in-One Bootstrap)"
    echo "  6) 連線測試 (Connectivity Check)"
    echo "  7) 檢視主機清單 (Show Inventory)"
    echo "  8) 測試 Ansible 連線 (Ping Test)"
    echo "  0) 離開 (Exit)"
    echo ""
}

show_inventory() {
    print_info "主機清單內容："
    cat inventory/staging
}

ping_test() {
    print_info "測試 Ansible 連線..."
    ansible -i inventory/staging all -m ping
}

# ==========================================
# 主程式
# ==========================================

print_banner
check_prerequisites

# 互動式選單
while true; do
    show_menu
    read -p "請輸入選項 [0-8]: " choice
    
    case $choice in
        1)
            run_preflight_check
            ;;
        2)
            run_base_setup
            ;;
        3)
            run_system_hardening
            ;;
        4)
            run_web_server_setup
            ;;
        5)
            run_complete_bootstrap
            ;;
        6)
            run_connectivity_check
            ;;
        7)
            show_inventory
            ;;
        8)
            ping_test
            ;;
        0)
            print_info "再見！"
            exit 0
            ;;
        *)
            print_error "無效的選項，請重新選擇"
            ;;
    esac
    
    echo ""
    read -p "按 Enter 繼續..."
done
