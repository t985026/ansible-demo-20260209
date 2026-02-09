# 快速安裝指南 - Ubuntu/RHEL 環境建置

本文件說明如何在全新安裝的 Ubuntu 或 RHEL 系統上快速建置完整的執行環境。

## 📋 系統需求

### 支援的作業系統

- **Ubuntu**: 20.04 LTS, 22.04 LTS, 24.04 LTS
- **RHEL/CentOS/Rocky/AlmaLinux**: 7.x, 8.x, 9.x

### 最低硬體需求

- **CPU**: 2 Core
- **記憶體**: 2 GB RAM
- **磁碟空間**: 10 GB 可用空間
- **網路**: 可存取外部網路 (用於套件下載)

### 軟體需求

- **Python**: 3.6+
- **SSH**: OpenSSH Server
- **Sudo**: 管理者權限

---

## 🚀 快速開始 (5 分鐘部署)

### 步驟 1：準備 Control Node (控制節點)

在您的本機或跳板機上安裝 Ansible：

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install ansible sshpass -y
```

#### RHEL/CentOS

```bash
sudo yum install epel-release -y
sudo yum install ansible sshpass -y
```

#### 驗證安裝

```bash
ansible --version
```

### 步驟 2：下載專案並配置

```bash
# 進入專案目錄
cd /path/to/project

# 賦予執行腳本權限
chmod +x deploy.sh

# 編輯 inventory 檔案，設定目標主機
vim inventory/staging
```

**inventory/staging 範例：**

```ini
[webservers]
192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[security_targets]
192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 步驟 3：執行部署

#### 方法 A：使用互動式腳本 (推薦)

```bash
./deploy.sh
```

選擇選項 5 執行完整部署。

#### 方法 B：手動執行 Playbook

##### 1. 前置檢查

```bash
ansible-playbook -i inventory/staging preflight_check.yml
```

##### 2. 基礎環境建置

```bash
ansible-playbook -i inventory/staging base_system_setup.yml
```

##### 3. 系統加固 (可選)

```bash
ansible-playbook -i inventory/staging system_hardening.yml
```

##### 4. Web Server 部署 (可選)

```bash
ansible-playbook -i inventory/staging web_server_setup.yml
```

##### 5. 或執行完整部署

```bash
ansible-playbook -i inventory/staging complete_bootstrap.yml
```

---

## 📦 部署內容說明

### base_system_setup.yml (基礎環境建置)

此 playbook 會自動完成以下設定：

#### 系統設定

- ✅ 驗證作業系統版本
- ✅ 設定時區為 Asia/Taipei
- ✅ 更新所有系統套件
- ✅ 安裝基礎工具 (vim, git, curl, wget, htop 等)
- ✅ 設定 Python 環境

#### 網路與安全

- ✅ 測試外部網路連線
- ✅ 設定防火牆 (UFW for Ubuntu, firewalld for RHEL)
- ✅ 允許 SSH 連線
- ✅ 安裝並啟用 NTP 時間同步 (chrony)

#### 效能優化

- ✅ 調整系統資源限制 (nofile, nproc)
- ✅ 優化核心參數 (sysctl)
- ✅ 設定日誌輪替 (logrotate)

#### 目錄結構

建立標準化目錄：

```
/opt/apps          # 應用程式安裝目錄
/opt/scripts       # 腳本存放目錄
/opt/backups       # 備份檔案目錄
/var/log/ansible_managed_app  # 應用程式日誌目錄
```

### system_hardening.yml (系統加固)

執行資安基線設定：

- 🔒 建立專用管理帳號 (sysadmin) 和稽核帳號 (auditor)
- 🔒 鎖定 root 帳號密碼登入
- 🔒 SSH 安全加固
  - 禁止 root 登入
  - 禁用密碼認證 (強制使用 SSH Key)
  - 設定閒置逾時 (300 秒)
  - 限制認證嘗試次數 (3 次)
- 🔒 安裝 Fail2Ban 防暴力破解
- 🔒 啟用防火牆並設定預設拒絕政策

### web_server_setup.yml (Web Server 部署)

部署並配置 Nginx：

- 🌐 安裝 Nginx 網頁伺服器
- 🌐 建立專用 Web 管理帳號 (webadmin)
- 🌐 部署自訂首頁 (使用 Jinja2 模板)
- 🌐 配置 Nginx (自訂設定檔)
- 🌐 設定防火牆允許 HTTP/HTTPS (port 80/443)
- 🌐 建立日誌目錄並設定權限

---

## 🔧 進階配置

### 修改變數設定

所有可調整的變數集中在 `group_vars/` 目錄：

#### group_vars/all.yml (全域變數)

```yaml
admin_user: sysadmin        # 管理員帳號名稱
audit_user: auditor         # 稽核員帳號名稱
log_dir: /var/log/ansible_managed_app  # 日誌目錄
```

#### group_vars/webservers.yml (Web Server 專用)

```yaml
web_root: /var/www/my_custom_site  # 網站根目錄
web_user: webadmin                  # Web 管理帳號
```

#### group_vars/security_targets.yml (安全加固專用)

```yaml
allow_ssh_password_auth: no  # 是否允許 SSH 密碼登入
```

### 自訂部署範圍

#### 僅部署特定 tag

```bash
# 只執行基礎設定，跳過安全加固
ansible-playbook -i inventory/staging base_system_setup.yml --tags "base"

# 只執行防火牆設定
ansible-playbook -i inventory/staging base_system_setup.yml --tags "firewall"
```

#### 限制目標主機

```bash
# 只對特定主機執行
ansible-playbook -i inventory/staging base_system_setup.yml --limit "192.168.1.100"

# 對 webservers 群組執行
ansible-playbook -i inventory/staging base_system_setup.yml --limit "webservers"
```

### Dry Run (模擬執行)

```bash
# 檢查會執行哪些變更，但不實際執行
ansible-playbook -i inventory/staging base_system_setup.yml --check
```

---

## 🧪 驗證部署結果

### 1. 檢查系統狀態

```bash
# 執行連線測試
ansible-playbook -i inventory/staging tools/connectivity_check.yml

# 或手動檢查
ansible -i inventory/staging all -m shell -a "uptime"
ansible -i inventory/staging all -m shell -a "df -h"
```

### 2. 驗證服務狀態

#### SSH 到目標主機後執行

```bash
# 檢查防火牆狀態
sudo ufw status         # Ubuntu
sudo firewall-cmd --list-all  # RHEL

# 檢查時間同步
sudo systemctl status chronyd

# 檢查 Nginx (如果有部署)
sudo systemctl status nginx
curl http://localhost
```

### 3. 檢查安全設定

```bash
# 檢查 SSH 設定
sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config

# 檢查管理帳號
id sysadmin
id auditor
id webadmin  # 如果有部署 Web Server

# 檢查 Fail2Ban
sudo systemctl status fail2ban
sudo fail2ban-client status sshd
```

---

## ⚠️ 注意事項

### 首次執行注意

1. **SSH Key 認證**：建議使用 SSH Key 而非密碼
2. **Sudo 權限**：確保 ansible_user 具有 sudo 權限
3. **防火牆**：執行加固後會啟用防火牆，確保 SSH port 已開放
4. **備份**：建議先在測試環境驗證，再部署到正式環境

### 密碼管理

密碼相關變數存放在 `secrets/credentials.yml`，建議使用 ansible-vault 加密：

```bash
# 加密 secrets 檔案
ansible-vault encrypt secrets/credentials.yml

# 執行 playbook 時解密
ansible-playbook -i inventory/staging base_system_setup.yml --ask-vault-pass
```

### Production 環境部署

將 inventory 檔案改為 `inventory/production`：

```bash
ansible-playbook -i inventory/production complete_bootstrap.yml
```

---

## 🐛 故障排除

### 常見問題

#### 1. SSH 連線失敗

```bash
# 手動測試 SSH 連線
ssh -i ~/.ssh/id_rsa ubuntu@192.168.1.100

# 檢查 SSH agent
ssh-add -l
```

#### 2. Sudo 權限不足

編輯目標主機的 `/etc/sudoers`：

```bash
# 允許 ubuntu 使用者無密碼執行 sudo
ubuntu ALL=(ALL) NOPASSWD:ALL
```

#### 3. 套件安裝失敗

```bash
# 手動更新套件來源
sudo apt update  # Ubuntu
sudo yum clean all && sudo yum update  # RHEL
```

#### 4. 防火牆阻擋連線

```bash
# 臨時停用防火牆進行測試
sudo ufw disable  # Ubuntu
sudo systemctl stop firewalld  # RHEL
```

### 啟用詳細日誌

```bash
# 執行時增加 verbose 輸出
ansible-playbook -i inventory/staging base_system_setup.yml -vvv
```

---

## 📚 延伸閱讀

- [操作手冊](03_Operation_Manual.md) - 詳細的日常維運指南
- [技術架構](02_Technical_Architecture.md) - 架構設計說明
- [產品規格](01_PRD.md) - 專案需求與規格

---

## 📞 支援

如有問題或建議，請聯繫 DevOps 團隊。

**最後更新**: 2026-01-27  
**版本**: v1.0
