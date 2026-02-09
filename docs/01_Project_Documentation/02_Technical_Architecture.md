# 02. 技術架構設計書 (Technical Architecture Design)

| 文件資訊 | 內容 |
| :--- | :--- |
| **文件由來** | Ansible 架構優化專案 |
| **文件編號** | TECH-20260116-v1.0 |
| **更新日期** | 2026-01-16 |

## 1. 架構總覽 (Architecture Overview)

本專案採用 Ansible 標準目錄結構 (Standard Directory Layout)，強調 **Inventory 與 Logic 的分離**。此設計確保存儲庫 (Repository) 可同時支援多個環境 (Staging, Production) 而無需修改程式碼。

### 1.1 目錄結構樹

```text
Ansible/project/
├── docs/                       # 專案文件中心
├── inventory/                  # [Inventory Layer] 環境定義
│   ├── production              # 正式環境主機清單
│   └── staging                 # 測試環境主機清單
├── group_vars/                 # [Variable Layer] 變數配置
│   ├── all.yml                 # 全域變數 (Global Defaults)
│   ├── webservers.yml          # Web Server 群組變數
│   └── security_targets.yml    # 加固目標群組變數
├── web_server_setup.yml        # [Execution Layer] 網頁部署邏輯
└── system_hardening.yml        # [Execution Layer] 加固邏輯
```

## 2. Inventory 與分群設計

我們採用 **功能性分群 (Functional Grouping)** 策略，將主機依據其角色進行分類。

- **`[webservers]`**：所有負責提供 HTTP/HTTPS 服務的主機。
- **`[security_targets]`**：所有需要進行基線加固的主機 (通常包含 webservers)。

### 環境隔離策略

透過在命令列指定不同的 Inventory 檔案來實現環境隔離：

- **Staging**: `ansible-playbook -i inventory/staging ...`
- **Production**: `ansible-playbook -i inventory/production ...`

## 3. 變數管理與優先權 (Variable Precedence)

本架構遵循 Ansible 變數優先權邏輯，由廣泛到特定：

1. **`group_vars/all.yml`**：定義最低優先級的預設值 (例如：預設的管理員帳號名稱)。
2. **`group_vars/<group_name>.yml`**：定義特定群組的覆蓋值 (例如：Web Server 特有的路徑配置)。
3. **Inventory Host Vars** (本案暫未使用)：若有單機特殊需求，可於 Inventory 檔案中定義。

## 4. Playbook 設計模式

### 4.1 Web Server Setup (`web_server_setup.yml`)

- **角色**：配置管理 (Configuration Management)
- **關鍵模組**：`apt` (安裝 Nginx), `template` (配置檔), `file` (權限管理)。
- **邏輯**：確保 Nginx 服務狀態 -> 部署靜態檔案 -> 設定防火牆 -> 啟動服務。

### 4.2 System Hardening (`system_hardening.yml`)

- **角色**：安全性合規 (Security Compliance)
- **關鍵模組**：`user` (帳號鎖定), `lineinfile` (SSHD 配置), `ufw` (網路存取控制)。
- **邏輯**：建立管理帳號 -> 封鎖 Root 登入 -> 設定 SSH 安全參數 -> 啟用防火牆阻擋未授權存取。

## 5. 網路與安全性設計

- **Control Node -> Managed Node**：透過 SSH (TCP 22) 進行加密連線。
- **Managed Node**：
  - **Inbound**：預設 Deny All。
    - Allow TCP 22 (SSH) from Control Node / Admin subnet。
    - Allow TCP 80/443 (HTTP/HTTPS) for Web Servers。
  - **Outbound**：預設 Allow All (用於 apt update, curl 等)。
