# Ansible Demo - Killercoda 快速啟動指南

本 Demo 專為 Killercoda 等線上學習環境設計，提供完整的 Ansible 自動化部署示範。

## 📋 環境需求

- **平台**: Killercoda Ubuntu Playground（2 節點）
- **Ansible 版本**: 2.9+
- **目標主機**: controlplane + node01

## 🚀 快速啟動（3 步驟）

### 步驟 1: 安裝 Ansible

```bash
# 在 controlplane 執行
apt update
apt install ansible -y
ansible --version
```

### 步驟 2: 配置 SSH 免密碼登入

```bash
# 生成 SSH 金鑰（一路按 Enter）
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa

# 複製金鑰到 node01
ssh-copy-id node01

# 測試連線
ssh node01 "hostname"
```

### 步驟 3: 執行部署腳本

```bash
# 下載或克隆專案
cd demo

# 賦予執行權限
chmod +x deploy.sh

# 執行自動化部署
./deploy.sh
```

## 📝 手動執行方式

如果您想逐步了解每個指令：

```bash
# 1. 檢查連線
ansible -i inventory/hosts all -m ping

# 2. 執行 Playbook
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml

# 3. 驗證部署結果
curl http://node01
```

## 🔍 驗證部署成功

部署完成後，您應該看到：

1. ✓ Nginx 已安裝並執行
2. ✓ 網站目錄已創建 (`/var/www/demo`)
3. ✓ 自訂首頁已部署

**測試網站**：

```bash
curl http://node01
# 應該顯示包含主機名稱的歡迎頁面
```

## 📂 檔案結構說明

```
demo/
├── deploy.sh              # 自動化部署腳本
├── group_vars/            # 群組變數目錄（Ansible 自動載入）
│   ├── all.yml           # 所有主機共用的變數
│   └── webservers.yml    # webservers 群組專用變數
├── inventory/
│   └── hosts             # 主機清單（controlplane + node01）
├── tasks/                 # Playbook 目錄 ⭐
│   └── web_server_setup.yml  # 主要 Playbook
├── templates/
│   ├── index.html.j2     # 網頁模板（使用 Jinja2）
│   └── nginx.conf.j2     # Nginx 配置模板
└── Readme.md             # 本文件
```

## 🎓 學習重點

本 Demo 涵蓋以下 Ansible 核心概念：

1. **Inventory 管理**: 定義目標主機
2. **Playbook 編寫**: YAML 格式的自動化腳本
3. **模組使用**: apt, service, file, user, template 等
4. **變數與模板**: Jinja2 模板引擎
5. **Handlers**: 事件觸發的任務（如重啟服務）

## ⚠️ 常見問題

### Q: SSH 連線失敗？

A: 確保已執行 `ssh-copy-id node01` 並測試 SSH 連線

### Q: Playbook 執行失敗？

A: 檢查 Ansible 版本，確保使用 2.9 以上版本

### Q: 無法訪問網站？

A: 確認 Nginx 服務狀態：`ssh node01 "systemctl status nginx"`

## 🔗 延伸學習

- 修改 `templates/index.html.j2` 自訂網頁內容
- 調整 `group_vars/webservers.yml` 中的變數（web_root, log_dir, web_user）
- 在 `group_vars/all.yml` 添加全域變數
- 嘗試添加更多主機到 `inventory/hosts`
- 學習 Ansible 變數優先級：group_vars vs host_vars
- 創建 `host_vars/` 目錄為特定主機定義變數

---

**說明**: 本 Demo 已針對 Killercoda 環境優化，所有路徑和配置均已測試驗證。
