# Ansible Automation Project

本專案提供標準化的伺服器部署與安全性加固自動化方案。

## 📂 專案文件 (Documentation)

所有的專案文件已移至 `docs/` 目錄，請參閱以下連結：

- **[🚀 快速安裝指南 (Installation Guide)](docs/INSTALLATION_GUIDE.md)** ⭐ **NEW**
  - 全新安裝 Ubuntu/RHEL 後的完整環境建置指南
- **[01. 產品需求規格書 (PRD)](docs/01_PRD.md)**
  - 專案目標、範圍與詳細需求規格。
- **[02. 技術架構設計書 (Technical Architecture)](docs/02_Technical_Architecture.md)**
  - 目錄結構、變數管理策略與網路架構設計。
- **[03. 系統營運操作手冊 (Operation Manual)](docs/03_Operation_Manual.md)**
  - 標準作業程序 (SOP)、環境準備與故障排除。

## 🚀 快速開始 (Quick Start)

### 新系統完整部署 (推薦)

#### 方法 A：使用互動式腳本

```bash
chmod +x deploy.sh
./deploy.sh
```

#### 方法 B：一鍵部署

```bash
# 完整部署 (基礎環境 + 加固 + Web Server)
ansible-playbook -i inventory/staging complete_bootstrap.yml

# 或僅部署基礎環境
ansible-playbook -i inventory/staging base_system_setup.yml
```

### 個別元件部署

### 1. 基礎環境建置 (Ubuntu/RHEL 系統初始化)

```bash
ansible-playbook -i inventory/staging base_system_setup.yml
```

### 2. 部署網頁伺服器

```bash
ansible-playbook -i inventory/staging web_server_setup.yml
```

### 3. 系統加固

```bash
ansible-playbook -i inventory/staging system_hardening.yml
```

---

## 📋 可用的 Playbooks

| Playbook | 用途 | 執行指令 |
|----------|------|----------|
| `preflight_check.yml` | 前置系統檢查 | `ansible-playbook -i inventory/staging preflight_check.yml` |
| `base_system_setup.yml` | 基礎環境建置 | `ansible-playbook -i inventory/staging base_system_setup.yml` |
| `system_hardening.yml` | 系統安全加固 | `ansible-playbook -i inventory/staging system_hardening.yml` |
| `web_server_setup.yml` | Web Server 部署 | `ansible-playbook -i inventory/staging web_server_setup.yml` |
| `complete_bootstrap.yml` | 完整系統部署 | `ansible-playbook -i inventory/staging complete_bootstrap.yml` |
| `tools/connectivity_check.yml` | 連線測試 | `ansible-playbook -i inventory/staging tools/connectivity_check.yml` |

---
*詳細操作與變數設定請參閱 [快速安裝指南](docs/INSTALLATION_GUIDE.md) 或 [操作手冊](docs/03_Operation_Manual.md)。*
