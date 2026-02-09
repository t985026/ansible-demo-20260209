# ✅ Demo 目錄最終配置總結

## 🎯 專案狀態

**版本**: 1.1  
**最後更新**: 2026-02-09 14:07  
**狀態**: ✅ 已完成 Killercoda 適配與優化

## 📂 最終目錄結構

```
demo/
├── deploy.sh                    # 主要部署腳本
├── tasks/                       # Playbook 目錄 ⭐
│   └── web_server_setup.yml     # Ansible Playbook (14 tasks)
├── group_vars/                  # 變數管理（Ansible 標準結構）
│   ├── all.yml                 # 全域變數
│   └── webservers.yml          # webservers 群組變數
├── inventory/
│   └── hosts                   # 主機清單（controlplane + node01）
├── templates/
│   ├── index.html.j2           # 網頁模板
│   └── nginx.conf.j2           # Nginx 配置模板
├── Readme.md                    # 使用說明（完整版）
├── CHANGELOG.md                 # 版本更新記錄
├── CHECKLIST.md                 # 部署檢查清單
├── KILLERCODA_QUICKSTART.md     # 快速啟動指令集
├── VARS_EXTERNALIZATION.md      # 變數管理詳細說明
└── verify_environment.sh        # 環境驗證腳本
```

## 🔧 核心配置文件

### 1. group_vars/webservers.yml

```yaml
---
# Ansible Demo - Web Server Variables
# 此文件定義 tasks/web_server_setup.yml 所需的所有變數

# 網站相關配置
web_root: /var/www/demo
log_dir: /var/log/nginx_custom
web_user: webadmin
```

### 2. group_vars/all.yml

```yaml
---
# Ansible Demo - All Groups Variables
# 適用於所有主機的全域變數

# 管理員帳號（所有主機共用）
admin_user: ansible_admin
```

### 3. inventory/hosts

```ini
[servers]
controlplane
node01

[webservers]
node01
```

### 4. tasks/web_server_setup.yml

- **總任務數**: 14 個
- **執行階段**: 6 個（基礎安裝、服務管理、環境配置、權限管理、內容部署、驗證）
- **變數載入**: 自動從 group_vars/ 載入，無需手動聲明

## ✅ 主要變更記錄

### 版本 1.1 (2026-02-09)

1. **移除防火牆配置**
   - ❌ 移除 UFW 防火牆相關任務
   - ✅ 適配 Killercoda 環境（預設無防火牆）
   - ✅ 減少任務數從 20 → 14

2. **變數管理標準化**
   - ✅ 採用 `group_vars/` 標準目錄結構
   - ✅ 創建 `group_vars/webservers.yml` 和 `group_vars/all.yml`
   - ✅ 移除 Playbook 中的 `vars_files` 聲明
   - ✅ 利用 Ansible 自動載入機制

3. **文檔完善**
   - ✅ 更新所有文檔使用統一的 group_vars 路徑
   - ✅ 添加詳細的變數管理說明
   - ✅ 提供 Killercoda 快速啟動指南

## 🚀 在 Killercoda 上的使用

### 一鍵部署（完整流程）

```bash
# 1. 環境準備
apt update && apt install ansible git -y

# 2. SSH 配置
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
ssh-copy-id -o StrictHostKeyChecking=no node01

# 3. 克隆專案
git clone https://github.com/t985026/ansible-demo-20260209.git
cd ansible-demo-20260209/demo

# 4. 驗證環境
chmod +x verify_environment.sh
./verify_environment.sh

# 5. 執行部署
chmod +x deploy.sh
./deploy.sh

# 6. 驗證結果
curl http://node01
```

### 預期結果

✅ **成功部署後應看到**:

1. Nginx 已安裝並執行
2. 網站目錄已創建 (`/var/www/demo`)
3. 自訂首頁已部署
4. 所有任務狀態為 `ok` 或 `changed`

## 📊 技術特點

### Ansible 最佳實踐

- ✅ 使用 `group_vars/` 目錄結構
- ✅ 變數自動載入機制
- ✅ 模組化 templates (Jinja2)
- ✅ Handlers 事件驅動
- ✅ 清晰的任務註解

### Killercoda 優化

- ✅ 移除防火牆依賴
- ✅ 適配 2 節點環境
- ✅ 快速驗證腳本
- ✅ 完整錯誤排查指南

## 🎓 學習重點

本 Demo 涵蓋的 Ansible 核心概念：

1. **Inventory 管理** - 主機和群組定義
2. **變數管理** - group_vars 標準結構
3. **Playbook 編寫** - YAML 格式和任務組織
4. **模組使用** - apt, service, file, user, template 等
5. **Jinja2 模板** - 動態配置文件生成
6. **Handlers** - 事件觸發機制
7. **變數優先級** - group_vars < host_vars < playbook vars

## 🔍 故障排除

### 常見問題

1. **SSH 連線失敗**

   ```bash
   ssh-copy-id -o StrictHostKeyChecking=no node01
   ```

2. **變數未正確載入**

   ```bash
   ansible -i inventory/hosts webservers -m debug -a "var=web_root"
   ```

3. **語法錯誤**

   ```bash
   ansible-playbook --syntax-check tasks/web_server_setup.yml
   ```

4. **模擬執行（不實際改變系統）**

   ```bash
   ansible-playbook -i inventory/hosts tasks/web_server_setup.yml --check
   ```

## 📖 延伸學習資源

### 官方文檔

- [Ansible 官方文檔](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Sample Directory Layout](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)

### 專案內文檔

- `Readme.md` - 完整使用說明
- `VARS_EXTERNALIZATION.md` - 變數管理詳解
- `KILLERCODA_QUICKSTART.md` - 快速啟動指令
- `CHECKLIST.md` - 部署檢查清單
- `CHANGELOG.md` - 版本更新記錄

## 🔗 相關連結

- **GitHub**: <https://github.com/t985026/ansible-demo-20260209>
- **Killercoda**: <https://killercoda.com/>
- **Ansible Galaxy**: <https://galaxy.ansible.com/>

## ✨ 下一步建議

### 1. 功能擴充

- 添加 SSL/TLS 證書配置
- 整合 Let's Encrypt
- 添加日誌輪轉配置
- 實作監控和告警

### 2. 結構優化

- 創建 Ansible Roles
- 添加 host_vars/ 支持
- 增加環境配置（dev/staging/prod）
- 整合 CI/CD 流程

### 3. 安全強化

- 使用 Ansible Vault 加密敏感數據
- 實作 SSH 金鑰輪換
- 添加審計日誌
- 整合安全掃描工具

---

**維護者**: Ansible Demo Project Team  
**授權**: MIT License  
**貢獻**: 歡迎提交 Pull Requests 和 Issues
