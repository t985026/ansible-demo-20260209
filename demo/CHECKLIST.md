# ✅ Killercoda 部署檢查清單

## 📋 修正內容總結

### 1. 修復的問題

- ✅ **deploy.sh**: 移除重複函數定義，修正執行流程
- ✅ **web_server_setup.yml**: 修復第 83 行錯誤的 Nginx 配置檔路徑
- ✅ **web_server_setup.yml**: 添加 vars 段落，定義必要變數
- ✅ **Readme.md**: 擴充為完整的 Killercoda 使用指南

### 2. 新增的檔案

- ✅ **verify_environment.sh**: 環境驗證腳本
- ✅ **KILLERCODA_QUICKSTART.md**: 快速啟動指令參考
- ✅ **CHECKLIST.md**: 本檢查清單

## 🎯 在 Killercoda 上的執行步驟

### 前置準備（在 Killercoda 的 controlplane 執行）

```bash
# 1. 安裝 Ansible
apt update && apt install ansible git -y

# 2. 設定 SSH 金鑰
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
ssh-copy-id -o StrictHostKeyChecking=no node01

# 3. 測試 SSH 連線
ssh node01 "hostname"
```

### 下載與執行

```bash
# 4. 克隆專案
git clone https://github.com/t985026/ansible-demo-20260209.git
cd ansible-demo-20260209/demo

# 5. 驗證環境
chmod +x verify_environment.sh
./verify_environment.sh

# 6. 執行部署
chmod +x deploy.sh
./deploy.sh
```

### 驗證結果

```bash
# 7. 測試網站
curl http://node01

# 8. 檢查 Nginx 狀態
ssh node01 "systemctl status nginx"

# 9. 查看部署的檔案
ssh node01 "ls -la /var/www/demo"
```

## 📁 檔案結構確認

```
demo/
├── deploy.sh                    ✅ 主要部署腳本
├── verify_environment.sh        ✅ 環境驗證腳本
├── KILLERCODA_QUICKSTART.md     ✅ 快速啟動指南
├── Readme.md                    ✅ 詳細說明文件
├── web_server_setup.yml         ✅ Ansible Playbook
├── inventory/
│   └── hosts                   ✅ 主機清單（controlplane + node01）
└── templates/
    ├── index.html.j2           ✅ 網頁模板
    └── nginx.conf.j2           ✅ Nginx 配置模板
```

## 🔍 關鍵配置確認

### inventory/hosts

```ini
[servers]
controlplane
node01

[webservers]
node01
```

### group_vars/webservers.yml - webservers 群組變數

```yaml
---
# Ansible Demo - Web Server Variables
# 此文件定義 web_server_setup.yml 所需的所有變數

# 網站相關配置
web_root: /var/www/demo
log_dir: /var/log/nginx_custom
web_user: webadmin
```

### group_vars/all.yml - 全域變數

```yaml
---
# 所有主機共用的變數
admin_user: ansible_admin
```

### web_server_setup.yml - 變數自動載入

```yaml
# Ansible 自動載入 group_vars/ 目錄下的變數
# 無需 vars_files 聲明
hosts: webservers  # 會自動載入 group_vars/webservers.yml
```

> **最佳實踐**: 使用 `group_vars/` 目錄結構，Ansible 會根據主機群組自動載入對應的變數文件。

### deploy.sh - 關鍵修正

- ✅ 路徑從 `hosts` 改為 `inventory/hosts`
- ✅ 移除重複的函數定義
- ✅ 正確的執行流程順序

## ⚠️ 常見錯誤排查

### 錯誤 1: SSH 連線失敗

**症狀**: `UNREACHABLE!` 錯誤
**解決**:

```bash
ssh-copy-id -o StrictHostKeyChecking=no node01
```

### 錯誤 2: Ansible 找不到主機

**症狀**: `Could not match supplied host pattern`
**解決**: 檢查 `inventory/hosts` 檔案格式

### 錯誤 3: 權限不足

**症狀**: `Permission denied`
**解決**: Playbook 已使用 `become: yes`，無需額外配置

## 🎓 預期執行結果

成功執行後，您應該看到：

1. ✅ 所有 tasks 顯示 `ok` 或 `changed`
2. ✅ 沒有 `failed` 或 `fatal` 錯誤
3. ✅ `curl http://node01` 顯示歡迎頁面
4. ✅ Nginx 服務狀態為 `active (running)`

## 📊 執行時間估算

- 環境準備: 2-3 分鐘
- Ansible 安裝: 1-2 分鐘
- Playbook 執行: 3-5 分鐘
- **總計**: 約 6-10 分鐘

## 🔗 相關資源

- **主專案**: <https://github.com/t985026/ansible-demo-20260209>
- **Killercoda 平台**: <https://killercoda.com/>
- **Ansible 官方文檔**: <https://docs.ansible.com/>

---

**最後更新**: 2026-02-09  
**測試環境**: Killercoda Ubuntu 20.04/22.04  
**Ansible 版本**: 2.9+
