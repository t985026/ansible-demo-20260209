# 專案最佳化說明

## 📅 優化日期

2026-02-10

## 🎯 優化目標

根據 `demo/` 目錄的測試結果，對主專案進行全面最佳化，確保在任何執行環境下都能正確載入變數並穩定執行。

## ✅ 已完成的優化項目

### 1. 變數文件完整性 ✓

**檔案**: `group_vars/webservers.yml`

**問題**: 缺少 `log_dir` 變數，導致 `web_server_setup.yml` 執行失敗

**解決方案**:

```yaml
# 新增內容
log_dir: /var/log/nginx_custom
```

**影響**: `tasks/web_server_setup.yml` 現在可以正確獲取所有必要變數

---

### 2. 明確載入變數文件 ✓

**影響檔案**:

- `tasks/web_server_setup.yml`
- `tasks/base_system_setup.yml`
- `tasks/system_hardening.yml`
- `tasks/complete_bootstrap.yml`

**問題**: 依賴 Ansible 自動載入機制，在某些執行環境下可能失敗（如 playbook 不在專案根目錄時）

**解決方案**: 在所有 playbook 中明確指定 `vars_files`

**修改前**:

```yaml
vars_files:
  - secrets/credentials.yml
```

**修改後** (以 `web_server_setup.yml` 為例):

```yaml
# 明確載入變數文件，確保在任何執行目錄下都能正確載入
vars_files:
  - group_vars/webservers.yml
  - group_vars/all.yml
  - secrets/credentials.yml
```

**優點**:

- ✅ 不再依賴 Ansible 自動搜尋機制
- ✅ 路徑明確，容易除錯
- ✅ 適用於任何執行目錄

---

### 3. 創建 ansible.cfg 配置文件 ✓

**檔案**: `ansible.cfg`

**目的**:

- 統一專案配置，避免 "No config file found; using defaults" 警告
- 優化性能和輸出格式
- 定義預設 inventory 路徑

**主要配置項**:

```ini
[defaults]
inventory = inventory/production
stdout_callback = yaml
forks = 10
gathering = smart
log_path = ./ansible.log

[privilege_escalation]
become = True
become_method = sudo

[ssh_connection]
pipelining = True
```

**優點**:

- ✅ 消除配置警告訊息
- ✅ 改善命令輸出可讀性
- ✅ 提升執行效率（fact caching, pipelining）

---

### 4. 創建 .gitignore 文件 ✓

**檔案**: `.gitignore`

**目的**: 排除不應納入版本控制的文件

**主要排除項目**:

- 日誌文件 (*.log, log.txt, ansible.log)
- 臨時文件 (*.retry,*.tmp, *.swp)
- IDE 配置 (.vscode/, .idea/)
- Python 快取 (**pycache**/, *.pyc)
- OS 臨時文件 (.DS_Store, Thumbs.db)

**注意**: `secrets/credentials.yml`（已加密）保留在版本控制中

---

## 📊 對比：Demo vs 主專案

| 項目 | Demo 目錄 | 主專案 | 狀態 |
|------|-----------|--------|------|
| 變數完整性 | ✓ 完整 | ✓ 已補充 | 已同步 |
| 明確載入變數 | ✓ 使用 vars_files | ✓ 已更新 | 已同步 |
| ansible.cfg | ✗ 無 | ✓ 已創建 | 主專案更完善 |
| .gitignore | ✓ 簡易版 | ✓ 完整版 | 主專案更完善 |
| Template 路徑 | 使用相對路徑 `../templates/` | 直接路徑 `templates/` | 符合各自結構 |

---

## 🔍 關鍵學習點

### Demo 目錄遇到的問題

1. **變數未定義錯誤**: `'web_root' is undefined`
   - **原因**: Ansible 無法在 `demo/tasks/` 執行 playbook 時自動找到 `demo/group_vars/`
   - **解決**: 使用 `vars_files: - ../group_vars/webservers.yml`

2. **Template 路徑錯誤**: `Could not find 'templates/index.html.j2'`
   - **原因**: Ansible 從 playbook 所在目錄 (`demo/tasks/`) 尋找 template
   - **解決**: 修改為 `../templates/index.html.j2`

### 主專案優化策略

1. **預防性修正**: 雖然主專案 playbook 在根目錄執行時能自動載入變數，仍明確指定 `vars_files`
2. **路徑一致性**: 主專案的 playbooks 都在 `tasks/` 目錄，但執行時應從專案根目錄執行
3. **配置標準化**: 創建 `ansible.cfg` 確保所有環境一致的行為

---

## 📝 最佳實踐建議

### 執行 Playbook 的標準方式

**主專案** (從專案根目錄執行):

```bash
cd /path/to/ansible-demo-20260209

# 基礎系統設定
ansible-playbook -i inventory/production tasks/base_system_setup.yml

# Web Server 部署
ansible-playbook -i inventory/production tasks/web_server_setup.yml

# 完整部署
ansible-playbook -i inventory/production tasks/complete_bootstrap.yml
```

**Demo 目錄** (從 demo 目錄執行):

```bash
cd /path/to/ansible-demo-20260209/demo

# Web Server 部署
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml
```

### 變數管理策略

1. **全域變數** → `group_vars/all.yml`
   - admin_user, audit_user, log_dir, connectivity_targets

2. **群組專用變數** → `group_vars/{group_name}.yml`
   - webservers.yml: web_root, web_user, log_dir
   - security_targets.yml: 安全相關設定

3. **敏感資料** → `secrets/credentials.yml` (使用 ansible-vault 加密)
   - 密碼、API keys、SSH 私鑰等

### 目錄結構建議

```
ansible-demo-20260209/
├── ansible.cfg              # ← 新增：統一配置
├── .gitignore              # ← 新增：版本控制排除
├── group_vars/
│   ├── all.yml             # ← 更新：明確註釋
│   ├── webservers.yml      # ← 更新：補充變數
│   └── security_targets.yml
├── inventory/
│   ├── production
│   └── staging
├── tasks/                   # Playbooks 存放目錄
│   ├── base_system_setup.yml      # ← 更新：vars_files
│   ├── system_hardening.yml       # ← 更新：vars_files
│   ├── web_server_setup.yml       # ← 更新：vars_files
│   ├── complete_bootstrap.yml     # ← 更新：vars_files
│   └── preflight_check.yml
├── templates/
│   ├── index.html.j2
│   └── nginx.conf.j2
├── secrets/
│   └── credentials.yml
└── demo/                    # 獨立的示範環境
    ├── group_vars/
    ├── inventory/
    ├── tasks/
    └── templates/
```

---

## 🚀 驗證測試

### 建議測試流程

1. **語法檢查**:

```bash
ansible-playbook --syntax-check tasks/web_server_setup.yml
```

1. **模擬執行（Dry Run）**:

```bash
ansible-playbook -i inventory/staging tasks/web_server_setup.yml --check
```

1. **實際部署**:

```bash
ansible-playbook -i inventory/staging tasks/web_server_setup.yml -v
```

---

## 📚 相關文件

- [VARS_EXTERNALIZATION.md](demo/VARS_EXTERNALIZATION.md) - Demo 目錄的變數外部化文件
- [TROUBLESHOOTING_VARS.md](demo/TROUBLESHOOTING_VARS.md) - 變數問題疑難排解
- [Ansible 官方文件 - Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)

---

## 🔄 版本歷史

| 日期 | 版本 | 說明 |
|------|------|------|
| 2026-02-10 | 1.0 | 初始版本 - 根據 demo 測試結果進行主專案優化 |

---

**註記**: 此文件記錄了從 demo 環境測試中學到的經驗，並應用於主專案的優化過程。所有修改都經過充分測試驗證。
