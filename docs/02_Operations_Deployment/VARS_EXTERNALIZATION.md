# 📁 Ansible 變數管理 - group_vars 標準結構

## 📋 變數管理概述

本專案採用 Ansible 標準的 `group_vars` 目錄結構來管理變數，這是 Ansible 社群公認的最佳實踐。

## 🎯 為什麼使用 group_vars？

### 優勢

1. **自動載入** - Ansible 會根據主機群組自動載入對應的變數文件
2. **結構清晰** - 目錄結構一目了然，便於管理和維護
3. **易於擴充** - 可輕鬆添加新的群組或主機特定變數
4. **優先級明確** - 變數優先級清晰可控
5. **符合慣例** - 遵循 Ansible 社群的約定俗成

### 與其他方式的比較

| 方式 | 優點 | 缺點 | 適用場景 |
|------|------|------|----------|
| **group_vars/** | 自動載入、結構清晰 | 需要遵循目錄結構 | ✅ 推薦用於所有專案 |
| `vars_files:` | 靈活指定文件 | 需手動聲明路徑 | 特殊情況或動態載入 |
| `vars:` | 簡單直接 | 不易重用、難以管理 | 簡單的單一 playbook |

## 📂 目錄結構

```
demo/
├── group_vars/              # 群組變數目錄
│   ├── all.yml             # 所有主機共用的全域變數
│   └── webservers.yml      # webservers 群組專用變數
├── host_vars/              # 主機變數目錄（可選）
│   ├── node01.yml          # node01 特定變數
│   └── controlplane.yml    # controlplane 特定變數
├── inventory/
│   └── hosts               # 主機清單
└── web_server_setup.yml    # Playbook
```

## 🔧 實際配置

### 1. inventory/hosts

定義主機和群組：

```ini
[servers]
controlplane
node01

[webservers]
node01
```

### 2. group_vars/all.yml

所有主機共用的變數：

```yaml
---
# Ansible Demo - 全域變數
# 適用於所有主機的共用配置

# 管理員帳號
admin_user: ansible_admin

# 其他全域配置
timezone: Asia/Taipei
ntp_server: time.stdtime.gov.tw
```

### 3. group_vars/webservers.yml

webservers 群組專用變數：

```yaml
---
# Ansible Demo - Web Server Variables
# 僅適用於 webservers 群組的主機

# 網站相關配置
web_root: /var/www/demo
log_dir: /var/log/nginx_custom
web_user: webadmin

# Nginx 配置
nginx_worker_processes: auto
nginx_worker_connections: 768
```

### 4. host_vars/node01.yml（可選）

特定主機的變數，會覆蓋群組變數：

```yaml
---
# node01 特定配置
web_root: /var/www/node01_custom  # 覆蓋 group_vars/webservers.yml
custom_service_port: 8080
```

### 5. web_server_setup.yml

Playbook 中無需聲明 vars_files，Ansible 會自動載入：

```yaml
---
- name: Web Server Deployment and Configuration
  hosts: webservers  # 會自動載入 group_vars/webservers.yml
  become: yes

  # 變數來源（自動載入，無需聲明）：
  # 1. group_vars/all.yml        - 所有主機
  # 2. group_vars/webservers.yml - webservers 群組
  # 3. host_vars/node01.yml      - node01 主機（如果存在）

  tasks:
    - name: Display variables
      debug:
        msg: "Web root is {{ web_root }}, managed by {{ admin_user }}"
```

## 📊 變數優先級

Ansible 變數優先級從低到高：

```
1. group_vars/all.yml           (最低 - 所有主機共用)
   ↓
2. group_vars/webservers.yml    (群組變數)
   ↓
3. host_vars/node01.yml         (主機特定變數)
   ↓
4. Playbook vars:               (Playbook 內定義)
   ↓
5. -e "var=value"               (最高 - 命令行參數)
```

### 優先級示例

假設有以下配置：

```yaml
# group_vars/all.yml
web_root: /var/www/default

# group_vars/webservers.yml
web_root: /var/www/demo

# host_vars/node01.yml
web_root: /var/www/node01
```

執行結果：

- **controlplane**: `/var/www/demo` (使用 webservers 群組變數)
- **node01**: `/var/www/node01` (host_vars 優先級最高)

## 🚀 使用方式

### 基本使用

```bash
# 直接執行，變數自動載入
ansible-playbook -i inventory/hosts web_server_setup.yml

# 查看變數值（調試用）
ansible -i inventory/hosts webservers -m debug -a "var=web_root"
```

### 環境特定配置

```bash
# 為不同環境創建不同的 group_vars
group_vars/
├── all.yml                 # 共用變數
├── webservers.yml          # 開發環境
├── webservers_staging.yml  # 測試環境
└── webservers_prod.yml     # 生產環境

# 使用符號連結切換環境
ln -sf webservers_prod.yml webservers.yml
```

### 加密敏感變數

```bash
# 使用 Ansible Vault 加密整個文件
ansible-vault encrypt group_vars/webservers.yml

# 執行時提供密碼
ansible-playbook -i inventory/hosts web_server_setup.yml --ask-vault-pass

# 或僅加密特定變數
ansible-vault encrypt_string 'my_secret_password' --name 'db_password'
```

## 🎓 進階技巧

### 1. 變數繼承與覆蓋

```yaml
# group_vars/all.yml
common_packages:
  - curl
  - git
  - vim

# group_vars/webservers.yml
# 擴充而非覆蓋
webserver_packages: "{{ common_packages + ['nginx', 'certbot'] }}"
```

### 2. 動態變數

```yaml
# group_vars/webservers.yml
# 使用 facts 和其他變數構建新變數
web_root: "/var/www/{{ inventory_hostname }}"
log_file: "{{ log_dir }}/{{ ansible_hostname }}.log"
```

### 3. 條件變數

```yaml
# group_vars/webservers.yml
# 根據 OS 設定不同值
nginx_package: "{{ 'nginx' if ansible_os_family == 'Debian' else 'nginx-mainline' }}"
```

## ✅ 最佳實踐

### DO ✅

1. **使用描述性的變數名稱**

   ```yaml
   web_root: /var/www/demo  # ✅ 清晰
   path: /var/www/demo      # ❌ 太模糊
   ```

2. **添加註解說明**

   ```yaml
   # Nginx worker 數量（建議設為 CPU 核心數）
   nginx_worker_processes: auto
   ```

3. **使用 YAML 多行字串**

   ```yaml
   nginx_config: |
     worker_processes auto;
     events {
       worker_connections 768;
     }
   ```

4. **群組變數分類清晰**

   ```
   group_vars/
   ├── all.yml           # 全域配置
   ├── webservers.yml    # Web 相關
   ├── databases.yml     # 資料庫相關
   └── monitoring.yml    # 監控相關
   ```

### DON'T ❌

1. **不要把所有變數都放在 all.yml**
   - 應該根據用途分類到對應的群組

2. **不要在多處定義相同變數**
   - 容易造成混淆和維護困難

3. **不要使用太深的巢狀結構**

   ```yaml
   # ❌ 避免
   config:
     web:
       server:
         nginx:
           root: /var/www
   
   # ✅ 簡化
   web_root: /var/www
   ```

## 🔍 調試與驗證

### 查看變數值

```bash
# 查看特定變數
ansible -i inventory/hosts node01 -m debug -a "var=web_root"

# 查看所有變數
ansible -i inventory/hosts node01 -m debug -a "var=hostvars[inventory_hostname]"
```

### 測試變數載入

```bash
# 語法檢查
ansible-playbook --syntax-check web_server_setup.yml

# 列出將執行的任務（不實際執行）
ansible-playbook -i inventory/hosts web_server_setup.yml --list-tasks

# Dry run（模擬執行）
ansible-playbook -i inventory/hosts web_server_setup.yml --check
```

## 📖 相關資源

- [Ansible 官方文檔 - 變數](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)
- [Ansible 官方文檔 - 變數優先級](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Sample directory layout](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)

---

**最後更新**: 2026-02-09  
**適用版本**: Ansible 2.9+  
**維護者**: Ansible Demo Project Team

## 📋 變更概述

將 Ansible Playbook 中的內嵌變數改為從外部文件載入，遵循 Ansible 最佳實踐。

## 🔄 具體變更

### 1. 創建外部變數文件

**文件**: `vars.yml` (原 `vars`)

**修改前** (shell 格式):

```bash
APID_AP=MID01XXXXX
http_port=8443
```

**修改後** (YAML 格式):

```yaml
---
# Ansible Demo Variables
# 用於 web_server_setup.yml

# 網站相關配置
web_root: /var/www/demo
log_dir: /var/log/nginx_custom
web_user: webadmin

# 原有變數 (保留以備擴充使用)
APID_AP: MID01XXXXX
http_port: 8443
```

### 2. 更新 Playbook

**文件**: `web_server_setup.yml`

**修改前**:

```yaml
---
- name: Web Server Deployment and Configuration
  hosts: webservers
  become: yes

  vars:
    web_root: /var/www/demo
    log_dir: /var/log/nginx_custom
    web_user: webadmin

  tasks:
    # ...
```

**修改後**:

```yaml
---
- name: Web Server Deployment and Configuration
  hosts: webservers
  become: yes

  # 從外部文件載入變數
  vars_files:
    - vars.yml

  tasks:
    # ...
```

### 3. 更新文檔

**更新的文件**:

- ✅ `Readme.md` - 檔案結構說明，延伸學習
- ✅ `CHECKLIST.md` - 關鍵配置確認
- ✅ `CHANGELOG.md` - 版本更新記錄

## 🎯 優勢與好處

### 1. **可維護性**

- 變數集中在一個文件中
- 修改變數不需要編輯 Playbook
- 減少出錯機會

### 2. **可重用性**

```yaml
# 多個 Playbook 可共用同一個變數文件
- name: Deploy Web Server
  vars_files:
    - vars.yml

- name: Configure Monitoring
  vars_files:
    - vars.yml
```

### 3. **環境管理**

```bash
# 可為不同環境創建不同的變數文件
vars.yml              # 開發環境
vars-staging.yml      # 測試環境
vars-production.yml   # 生產環境
```

```yaml
# 在 Playbook 中動態選擇
vars_files:
  - "vars-{{ env }}.yml"
```

### 4. **版本控制**

- 變數變更歷史清晰可見
- 便於 Code Review
- 易於追蹤問題

## 📚 Ansible 變數優先級參考

從高到低：

1. **命令行參數** (`-e "var=value"`)
2. **vars_files** (本次使用的方式)
3. **vars_prompt**
4. **vars** (Playbook 內嵌)
5. **host_vars/**
6. **group_vars/**
7. **inventory** 文件中的變數
8. **角色默認值** (role defaults)

## 🔍 驗證變更

### 測試命令

```bash
# 1. 語法檢查
ansible-playbook --syntax-check web_server_setup.yml

# 2. 變數檢查（查看所有變數）
ansible-playbook -i inventory/hosts web_server_setup.yml --list-tasks

# 3. 模擬執行（不實際改變系統）
ansible-playbook -i inventory/hosts web_server_setup.yml --check

# 4. 正式執行
ansible-playbook -i inventory/hosts web_server_setup.yml
```

### 預期結果

- ✅ Playbook 正常執行
- ✅ 變數正確載入（web_root, log_dir, web_user）
- ✅ 無錯誤訊息

## 💡 進階用法建議

### 1. 加密敏感變數

```bash
# 使用 Ansible Vault 加密變數文件
ansible-vault encrypt vars.yml

# 執行時提供密碼
ansible-playbook -i inventory/hosts web_server_setup.yml --ask-vault-pass
```

### 2. 變數模板化

```yaml
# vars.yml
---
web_root: "/var/www/{{ project_name }}"
log_dir: "/var/log/{{ project_name }}"
```

### 3. 條件變數載入

```yaml
vars_files:
  - vars.yml
  - "vars-{{ ansible_distribution }}.yml"  # Ubuntu, CentOS 等
  - [ "vars-{{ ansible_hostname }}.yml", "vars-default.yml" ]  # fallback
```

## 📖 相關資源

- [Ansible Variables 官方文檔](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Variable Precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)

---

**變更日期**: 2026-02-09  
**影響範圍**: Playbook 結構優化，不影響功能  
**測試狀態**: ✅ 已驗證
