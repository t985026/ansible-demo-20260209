# Ansible Automation Project

本專案提供標準化的伺服器部署與安全性加固自動化方案。

## 📂 專案文件 (Documentation)

所有的專案文件已移至 `docs/` 目錄，請參閱以下連結：

### 🎯 核心文件

- **[🚀🚀 文件導航總覽 (Documentation Index)](docs/README.md)**
  - 完整的文件結構與快速查找指南
- **[🚀🚀 快速安裝指南 (Installation Guide)](docs/02_Operations_Deployment/INSTALLATION_GUIDE.md)** ⭐ **推薦**
  - 全新安裝 Ubuntu/RHEL 後的完整環境建置指南

### 📋 專案規劃文件

- **[01. 產品需求規格書 (PRD)](docs/01_Project_Documentation/01_PRD.md)**
  - 專案目標、範圍與詳細需求規格
- **[02. 技術架構設計書 (Technical Architecture)](docs/01_Project_Documentation/02_Technical_Architecture.md)**
  - 目錄結構、變數管理策略與網路架構設計
- **[04. 專案路線圖 (Roadmap)](docs/01_Project_Documentation/04_Roadmap.md)**
  - 功能開發計畫與里程碑
- **[🔄 變更日誌 (CHANGELOG)](docs/01_Project_Documentation/CHANGELOG.md)** ⭐ **NEW**
  - 專案版本更新歷史與重要變更記錄

### 🛠️ 操作與部署文件

- **[03. 系統營運操作手冊 (Operation Manual)](docs/02_Operations_Deployment/03_Operation_Manual.md)**
  - 標準作業程序 (SOP)、環境準備與故障排除
- **[📁 變數管理指南 (Variables Externalization)](docs/02_Operations_Deployment/VARS_EXTERNALIZATION.md)** ⭐ **NEW**
  - group_vars 標準結構與最佳實踐
- **[✅ 部署檢查清單 (Deployment Checklist)](docs/02_Operations_Deployment/CHECKLIST.md)** ⭐ **NEW**
  - Killercoda 部署前檢查與常見問題排查
- **[⚡ 專案最佳化說明 (Optimization Guide)](OPTIMIZATION.md)** ⭐ **2026-02-10**
  - 基於 demo 測試的專案優化記錄與最佳實踐

### 📚 教學與培訓資源

- **[Ansible 進階教學 (Advanced Tutorial)](docs/03_Training_Materials/Ansible_Advanced_Tutorial.md)**
  - Templates、Handlers、Task Control 等進階主題
- **[培訓手冊 (Training Manual)](docs/03_Training_Materials/Training_Manual.md)**
  - 完整的培訓課程內容

## 🚀 快速開始 (Quick Start)

### 新系統完整部署 (推薦)

#### 下載專案

```bash
# === 下載專案===
git clone https://github.com/t985026/ansible-demo-20260209.git
cd ansible-demo-20260209
```

#### 方法 A：使用互動式腳本

```bash
chmod +x deploy.sh
./deploy.sh
```

#### 方法 B：一鍵部署

```bash
# 完整部署 (基礎環境 + 加固 + Web Server)
ansible-playbook -i inventory/staging tasks/complete_bootstrap.yml

# 或僅部署基礎環境
ansible-playbook -i inventory/staging tasks/base_system_setup.yml
```

### 個別元件部署

### 1. 基礎環境建置 (Ubuntu/RHEL 系統初始化)

```bash
ansible-playbook -i inventory/staging tasks/base_system_setup.yml
```

### 2. 部署網頁伺服器

```bash
ansible-playbook -i inventory/staging tasks/web_server_setup.yml
```

### 3. 系統加固

```bash
ansible-playbook -i inventory/staging tasks/system_hardening.yml
```

---

## 📋 可用的 Playbooks

| Playbook | 用途 | 執行指令 |
|----------|------|----------|
| `tasks/preflight_check.yml` | 前置系統檢查 | `ansible-playbook -i inventory/staging tasks/preflight_check.yml` |
| `tasks/base_system_setup.yml` | 基礎環境建置 | `ansible-playbook -i inventory/staging tasks/base_system_setup.yml` |
| `tasks/system_hardening.yml` | 系統安全加固 | `ansible-playbook -i inventory/staging tasks/system_hardening.yml` |
| `tasks/web_server_setup.yml` | Web Server 部署 | `ansible-playbook -i inventory/staging tasks/web_server_setup.yml` |
| `tasks/complete_bootstrap.yml` | 完整系統部署 | `ansible-playbook -i inventory/staging tasks/complete_bootstrap.yml` |
| `tools/connectivity_check.yml` | 連線測試 | `ansible-playbook -i inventory/staging tools/connectivity_check.yml` |

---

## 📚 延伸閱讀

- **[📖 完整文件導航](docs/README.md)** - 查看所有可用文件
- **[🔄 變更日誌](docs/01_Project_Documentation/CHANGELOG.md)** - 了解專案演進歷程
- **[📁 變數管理指南](docs/02_Operations_Deployment/VARS_EXTERNALIZATION.md)** - group_vars 最佳實踐

---

*詳細操作與變數設定請參閱 [快速安裝指南](docs/02_Operations_Deployment/INSTALLATION_GUIDE.md) 或 [操作手冊](docs/02_Operations_Deployment/03_Operation_Manual.md)。*
