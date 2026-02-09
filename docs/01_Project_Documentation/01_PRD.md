# 01. 產品需求規格書 (Product Requirements Document)

| 文件資訊 | 內容 |
| :--- | :--- |
| **專案名稱** | Ansible 自動化部署與加固專案 |
| **文件編號** | PRD-20260116-v1.0 |
| **版本** | v1.0 |
| **密等** | 內部限閱 (Internal Use Only) |
| **最後更新日期** | 2026-01-16 |

## 文件修訂紀錄 (Version Control)

| 版本 | 日期 | 修改人 | 修改內容說明 |
| :--- | :--- | :--- | :--- |
| v0.1 | 2026-01-16 | Ansible Consultant | 初稿建立 |
| v1.0 | 2026-01-16 | Ansible Consultant | 正式發布，包含架構重構內容 |

---

## 1. 專案概述 (Executive Summary)

本專案旨在建立一套標準化、自動化的伺服器管理機制。透過導入 Ansible 自動化工具，達成「基礎架構即程式碼 (IaC)」之目標，消除人工操作的不一致性，並強制執行統一的資安基線。

## 2. 專案權責與利害關係人 (Project Stakeholders)

| 角色 (Role) | 職責 (Responsibility) | 相關人員 |
| :--- | :--- | :--- |
| **Product Owner** | 定義專案目標與驗收標準 | 專案經理 |
| **DevOps Engineer** | 開發 Ansible Playbook 與維護 CI/CD | 開發團隊 |
| **SysAdmin** | 執行自動化腳本進行日常維運 | 維運團隊 |
| **Security Officer** | 審核系統加固規範與合規性 | 資安團隊 |

## 3. 專案範圍 (Scope)

### 3.1 包含範圍 (In-Scope)

- **網頁伺服器標準化**：Nginx 自動化安裝、配置與內容部署。
- **系統安全性加固 (System Hardening)**：OS 層級的安全設定，包含 SSH、使用者權限控制與防火牆。
- **架構優化**：建立 Production/Staging 環境分離的 Inventory 與變數管理機制。

### 3.2 不包含範圍 (Out-of-Scope)

- 應用程式本身的程式碼開發 (Application Development)。
- 硬體層級的維護或網路基礎建設設定。

## 4. 功能需求規格 (Functional Requirements)

| ID | 需求名稱 | 詳細規格描述 | 優先級 |
| :--- | :--- | :--- | :--- |
| **FR-01** | **Web Server Deployment** | 自動化部署 Nginx，並建立專屬運作帳號 (`webadmin`) 與日誌目錄。 | P0 |
| **FR-02** | **System Hardening** | 自動化設定 SSH (禁止 Root 登入、閒置逾時)、安裝 Fail2Ban、啟用 UFW。 | P0 |
| **FR-03** | **Environment Separation** | 支援多環境部署，需能透過 Inventory 區分正式環境與測試環境。 | P0 |
| **FR-04** | **Config Management** | 所有變數需透過 `group_vars` 進行管理，不得寫死於 Playbook 中。 | P1 |

## 5. 非功能需求 (Non-Functional Requirements)

- **可維護性**：Playbook 需遵循 Ansible Lint 規範，並具備完整註解。
- **冪等性 (Idempotency)**：重複執行腳本不應破壞現有服務或造成設定跑掉。
- **擴充性**：Inventory 架構需能支援未來擴充至數百台伺服器。

## 6. 假設與限制 (Assumptions & Constraints)

- **OS 版本**：目標主機為 Ubuntu 20.04/22.04 LTS。
- **網路環境**：Control Node 需可透過 SSH (Port 22) 存取目標主機。
- **權限**：執行帳號需具備 `sudo` 權限以進行系統層級變更。
