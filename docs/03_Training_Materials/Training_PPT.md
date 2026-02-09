---
marp: true
theme: default
paginate: true
backgroundColor: #fff
header: 'Ansible 自動化部署與加固專案'
footer: '© 2026 Training Session'
---
<!-- _class: lead -->

# Ansible 自動化部署與加固專案

## 教育訓練課程

**Infrastructure as Code 實務訓練**

講師：DevOps Team
日期：2026-01-29

---

## 課程議程 (Agenda)

1. **Ansible 基礎概念** (30 min)
2. **專案架構解析** (30 min)
3. **實作演練：Web Server 部署** (60 min)
4. **實作演練：系統加固** (60 min)
5. **日常維運操作** (45 min)
6. **機敏資料管理** (30 min)
7. **Q&A 與進階主題** (30 min)

**總時數：4.5 小時**

---

<!-- _class: lead -->

# Part 1

## Ansible 基礎概念

---

## 什麼是 Infrastructure as Code (IaC)?

### 傳統運維的挑戰 ❌

- 手動設定容易出錯
- 環境不一致 → "我的電腦可以跑" 問題
- 缺乏版本控制與審計軌跡
- 知識依賴老手，新人難上手

### IaC 的優勢 ✅

- **自動化、可重複執行**
- **配置即程式碼** → Git 版本管理
- **執行前可審查** → Code Review
- **新環境快速複製**

---

## Ansible 核心元件

```text
┌─────────────────────────┐
│   Control Node          │ ← 你的筆電/跳板機
│   (執行 Ansible)        │
└───────────┬─────────────┘
            │ SSH (Port 22)
            ▼
┌───────────────────────────────────┐
│     Managed Nodes (目標伺服器)     │
│  ┌──────┐  ┌──────┐  ┌──────┐     │
│  │Web-01│  │Web-02│  │DB-01 │     │
│  └──────┘  └──────┘  └──────┘     │
└───────────────────────────────────┘
```

**關鍵特性：無需在目標主機安裝 Agent！**

---

## Ansible 核心術語

| 術語                   | 說明                | 範例                           |
| :--------------------- | :------------------ | :----------------------------- |
| **Control Node** | 執行 Ansible 的機器 | 你的筆電                       |
| **Managed Node** | 被管理的目標主機    | Web Server, DB Server          |
| **Inventory**    | 主機清單            | `inventory/production`       |
| **Playbook**     | 工作腳本 (YAML)     | `web_server_setup.yml`       |
| **Module**       | 功能模組            | `apt`, `file`, `service` |
| **Task**         | 單一作業            | "安裝 Nginx"                   |

---

## Ansible 工作原理

```text
Step 1: 讀取 Inventory
        ↓
Step 2: SSH 連線至 Managed Nodes
        ↓
Step 3: 推送 Python 模組至遠端
        ↓
Step 4: 執行任務
        ↓
Step 5: 回傳結果
```

**優勢**：

- Push-based (主動推送)
- Agentless (無需 Agent)
- 使用標準 SSH 協定

---

## 冪等性 (Idempotency) 概念

> **核心理念：多次執行相同 Playbook，結果應該一致**

### 範例

```yaml
- name: 確保 Nginx 已安裝
  apt:
    name: nginx
    state: present
```

- **第 1 次執行**：安裝 Nginx → `Changed` ✨
- **第 2 次執行**：已安裝 → `OK (Skipped)` 🔄
- **第 N 次執行**：已安裝 → `OK (Skipped)` 🔄

**好處**：可以安全地重複執行，不會破壞環境

---

<!-- _class: lead -->

# Part 2

## 專案架構解析

---

## 專案目錄結構

```text
Ansible/project/
├── docs/                       # 📚 文件中心
│   ├── 01_PRD.md
│   ├── 02_Technical_Architecture.md
│   ├── 03_Operation_Manual.md
│   └── Training_Manual.md
│
├── inventory/                  # 🎯 環境定義
│   ├── production             # 正式環境
│   └── staging                # 測試環境
│
├── group_vars/                 # ⚙️ 變數配置
│   ├── all.yml                # 全域變數
│   ├── webservers.yml         # Web 群組變數
│   └── security_targets.yml
│
├── web_server_setup.yml        # 🚀 Web 部署邏輯
└── system_hardening.yml        # 🔒 系統加固邏輯
```

---

## Inventory 設計：功能性分群

### inventory/production

```ini
[webservers]
web-prod-01 ansible_host=10.1.1.10
web-prod-02 ansible_host=10.1.1.11

[security_targets]
web-prod-01
web-prod-02
db-prod-01 ansible_host=10.1.1.20
```

### 為什麼要分群？

✅ 一台主機可屬於多個群組
✅ 不同群組套用不同變數
✅ 精準鎖定執行目標

---

## 環境隔離策略

### 測試環境

```bash
ansible-playbook -i inventory/staging web_server_setup.yml
```

### 正式環境

```bash
# 先預演 (Dry Run)
ansible-playbook -i inventory/production web_server_setup.yml --check

# 確認無誤後執行
ansible-playbook -i inventory/production web_server_setup.yml
```

**關鍵**：透過不同 Inventory 檔案區分環境，Playbook 邏輯不變！

---

## 變數管理策略

### 變數優先權 (由低到高)

```text
1. group_vars/all.yml          ← 最低優先級 (全域預設)
         ↓
2. group_vars/webservers.yml   ← 群組變數覆蓋
         ↓
3. Inventory host_vars         ← 主機變數覆蓋
         ↓
4. Playbook vars               ← 最高優先級 (不建議)
```

### 實例

```yaml
# group_vars/all.yml
admin_user: ansible_admin  # 預設

# group_vars/webservers.yml
admin_user: webmaster      # Web Server 覆蓋預設值
```

---

<!-- _class: lead -->

# Part 3

## 實作演練：Web Server 部署

---

## 環境檢查 (Pre-flight Check)

### 步驟 1：檢查 Ansible 版本

```bash
ansible --version
```

### 步驟 2：測試 SSH 連通性

```bash
ansible -i inventory/staging all -m ping
```

**預期輸出**：

```
web-staging-01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## Playbook 解析：web_server_setup.yml

```yaml
---
- name: 自動化部署與配置 Nginx Web Server
  hosts: webservers    # 目標群組
  become: yes          # 使用 sudo
  
  tasks:
    - name: 安裝 Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes
  
    - name: 建立 Web 管理員
      user:
        name: "{{ admin_user }}"
        state: present
  
    - name: 部署預設網頁
      copy:
        content: "<h1>Welcome to Automated Deployment</h1>"
        dest: "{{ web_root }}/index.html"
```

---

## 執行部署

### 測試環境

```bash
ansible-playbook -i inventory/staging web_server_setup.yml
```

### 正式環境

```bash
# 預演模式
ansible-playbook -i inventory/production web_server_setup.yml --check

# 正式執行
ansible-playbook -i inventory/production web_server_setup.yml
```

### 驗證結果

```bash
curl http://web-staging-01
```

---

## 執行結果解析

```text
PLAY [自動化部署與配置 Nginx Web Server] **********************

TASK [Gathering Facts] ****************************************
ok: [web-staging-01]

TASK [安裝 Nginx] **********************************************
changed: [web-staging-01]

TASK [建立 Web 管理員] *****************************************
changed: [web-staging-01]

TASK [部署預設網頁] ********************************************
changed: [web-staging-01]

PLAY RECAP ****************************************************
web-staging-01    : ok=4    changed=3    unreachable=0    failed=0
```

- **ok**：任務成功，無變更
- **changed**：任務成功，有變更
- **failed**：任務失敗

---

<!-- _class: lead -->

# Part 4

## 實作演練：系統加固

---

## 安全基線 (Security Baseline)

企業級系統加固包含：

- ✅ 禁止 Root 直接登入
- ✅ 強制 SSH Key 認證
- ✅ SSH 閒置逾時 (5 分鐘)
- ✅ 啟用防火牆 (UFW)
- ✅ 入侵防禦 (Fail2Ban)

**參考標準**：CIS Benchmark, NIST

---

## Playbook 解析：system_hardening.yml

```yaml
---
- name: 系統安全性加固
  hosts: security_targets
  become: yes
  
  tasks:
    - name: 禁止 Root 登入
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
      notify: restart sshd
  
    - name: 啟用防火牆
      ufw:
        state: enabled
        policy: deny
```

---

## Handler 機制

```yaml
tasks:
  - name: 修改 SSH 設定
    lineinfile:
      path: /etc/ssh/sshd_config
      regexp: '^Port'
      line: 'Port 22'
    notify: restart sshd  # 觸發 Handler

handlers:
  - name: restart sshd
    service:
      name: sshd
      state: restarted
```

**好處**：

- 避免重複重啟服務
- Handler 在所有 Task 完成後才執行

---

## ⚠️ 執行加固前的重要提醒

### 警告：請勿在未建立備用連線的情況下執行

**建議步驟**：

1. ✅ 確保有 Console 存取權 (VNC/IPMI)
2. ✅ 開啟第二個 SSH 視窗保持連線
3. ✅ 執行加固腳本
4. ✅ 開第三個視窗測試新連線
5. ⚠️ 若無法連線，立即用第二個視窗回退

### 執行指令

```bash
ansible-playbook -i inventory/staging system_hardening.yml
```

---

## 加固後驗證

### 檢查 SSH 設定

```bash
ansible -i inventory/staging security_targets -m shell \
  -a "grep PermitRootLogin /etc/ssh/sshd_config"
```

### 檢查防火牆狀態

```bash
ansible -i inventory/staging security_targets -m shell \
  -a "ufw status"
```

**預期輸出**：

```
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
```

---

<!-- _class: lead -->

# Part 5

## 日常維運操作

---

## 變數調整 SOP

### ❌ 錯誤做法

```bash
# 直接 SSH 到主機手動改
ssh web-01
sudo vi /etc/nginx/sites-enabled/default
```

### ✅ 正確做法

```bash
# 1. 修改變數檔案
vi group_vars/webservers.yml

# 2. 執行 Playbook
ansible-playbook -i inventory/production web_server_setup.yml

# 3. 版本控制
git add group_vars/webservers.yml
git commit -m "Update web_root path"
git push
```

---

## Ad-hoc 指令實戰

### 快速檢查磁碟使用率

```bash
ansible -i inventory/production all -m shell -a "df -h /"
```

### 批量重啟服務

```bash
ansible -i inventory/production webservers \
  -m service -a "name=nginx state=restarted" --become
```

### 收集系統資訊

```bash
ansible -i inventory/production all -m setup
```

---

## 常見故障排除

| 錯誤訊息                    | 原因            | 解決方案                        |
| :-------------------------- | :-------------- | :------------------------------ |
| `UNREACHABLE!`            | SSH 連線失敗    | 檢查 IP、測試 `ssh user@host` |
| `Missing sudo password`   | 需要 sudo 密碼  | 執行時加 `-K`                 |
| `apt: Could not get lock` | 背景 apt 在執行 | `ps aux \| grep apt`           |
| `Permission denied`       | SSH Key 未部署  | `ssh-copy-id user@host`       |

---

<!-- _class: lead -->

# Part 6

## 機敏資料管理

---

## 為什麼需要 Ansible Vault?

### ❌ 問題情境

```yaml
# group_vars/all.yml (未加密)
db_password: SuperSecret123  # 明碼存放
api_key: abc123xyz           # 推 Git 會外洩
ssh_private_key: |
  -----BEGIN RSA PRIVATE KEY-----
  ...
```

**風險**：

- Git History 永久保存明碼
- 所有有權限的人都能看到
- 外洩後難以追蹤

---

## Ansible Vault 基本操作

### 加密檔案

```bash
ansible-vault encrypt group_vars/all.yml
# 輸入加密密碼
```

### 檢視加密後內容

```bash
cat group_vars/all.yml
```

```
$ANSIBLE_VAULT;1.1;AES256
66386439653865343534653430653139613338...
```

### 編輯加密檔案

```bash
ansible-vault edit group_vars/all.yml
# 輸入密碼後自動解密並開啟編輯器
```

---

## 執行使用加密變數的 Playbook

### 方法 1：互動式輸入密碼

```bash
ansible-playbook -i inventory/production \
  web_server_setup.yml --ask-vault-pass
```

### 方法 2：使用密碼檔案 (CI/CD 適用)

```bash
echo "MyVaultPassword" > .vault_pass
chmod 600 .vault_pass

ansible-playbook -i inventory/production \
  web_server_setup.yml --vault-password-file .vault_pass
```

**⚠️ 重要**：`.vault_pass` 務必加入 `.gitignore`！

---

## 產生密碼雜湊

### 情境：建立 Linux 使用者需設定密碼

```bash
# 產生 SHA-512 雜湊
ansible all -i localhost, -m debug \
  -a "msg={{ 'MyPassword123' | password_hash('sha512') }}"
```

**輸出**：

```
$6$rounds=656000$YourSalt$HashValue...
```

### 應用

```yaml
- name: 建立使用者
  user:
    name: john
    password: "$6$rounds=656000$YourSalt$HashValue..."
```

---

<!-- _class: lead -->

# Part 7

## 進階主題與最佳實踐

---

## 版本控制整合

### .gitignore 範例

```gitignore
# Ansible 相關
*.retry
.vault_pass
*.log

# 機敏資料
inventory/production  # 若包含敏感 IP
group_vars/secrets.yml  # 未加密的秘密

# IDE
.vscode/
.idea/
```

### Git Workflow

```bash
git add playbooks/ group_vars/
git commit -m "feat: Add HTTPS support for web servers"
git push origin develop
```

---

## CI/CD 整合範例

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - deploy

syntax_check:
  stage: validate
  script:
    - ansible-playbook --syntax-check web_server_setup.yml

deploy_staging:
  stage: deploy
  script:
    - ansible-playbook -i inventory/staging web_server_setup.yml --check
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - ansible-playbook -i inventory/production web_server_setup.yml
  when: manual
  only:
    - main
```

---

## 效能優化技巧

### 平行執行

```ini
# ansible.cfg
[defaults]
forks = 20  # 同時對 20 台主機執行
```

### SSH 連線複用

```ini
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

### 使用 Mitogen (加速插件)

```bash
pip install mitogen
```

```ini
# ansible.cfg
[defaults]
strategy_plugins = /path/to/mitogen/ansible_mitogen/plugins/strategy
strategy = mitogen_linear
```

**效能提升：2-7 倍！**

---

## Ansible Lint 最佳實踐

### 安裝 Ansible Lint

```bash
pip install ansible-lint
```

### 執行檢查

```bash
ansible-lint web_server_setup.yml
```

### 常見規則

- ✅ 所有 Task 必須有 `name`
- ✅ 使用 FQCN 模組名稱 (`ansible.builtin.apt`)
- ✅ 避免使用 `command` 模組 (改用專用模組)
- ✅ 不要硬編碼變數於 Playbook

---

## 實作練習題

### 練習 1：基礎部署 (20 分鐘)

1. 修改 `group_vars/webservers.yml` 網站標題
2. 部署至 Staging 環境
3. 使用 `curl` 驗證

### 練習 2：安全加固 (30 分鐘)

1. 在 `system_hardening.yml` 新增 Task 安裝 `fail2ban`
2. 執行 Playbook
3. 驗證服務運作

### 練習 3：Vault 實戰 (20 分鐘)

1. 建立 `group_vars/secrets.yml`
2. 加密檔案
3. 撰寫 Playbook 讀取變數
4. 執行時使用 `--ask-vault-pass`

---

## 常用指令速查表

```bash
# === 基本測試 ===
ansible all -m ping
ansible all -m setup

# === Playbook 執行 ===
ansible-playbook playbook.yml
ansible-playbook playbook.yml --check      # Dry Run
ansible-playbook playbook.yml --step       # 逐步執行
ansible-playbook playbook.yml --list-hosts # 列出目標主機

# === Vault 管理 ===
ansible-vault encrypt file.yml
ansible-vault edit file.yml
ansible-vault view file.yml

# === Ad-hoc ===
ansible all -a "uptime"
ansible all -m apt -a "name=vim state=present" --become
```

---

## 參考資源

### 官方文件

- **Ansible Docs**：<https://docs.ansible.com/>
- **Best Practices**：<https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html>
- **Module Index**：<https://docs.ansible.com/ansible/latest/collections/>

### 內部文件

- [01_PRD.md](01_PRD.md) - 產品需求規格書
- [02_Technical_Architecture.md](02_Technical_Architecture.md) - 技術架構
- [03_Operation_Manual.md](03_Operation_Manual.md) - 操作手冊
- [Training_Manual.md](Training_Manual.md) - 教育訓練手冊

---

<!-- _class: lead -->

# Q&A

## 問題與討論

**感謝參與本次訓練！**

📧 聯絡資訊：<devops@example.com>
📚 專案文件：Confluence / GitLab Wiki
🔧 技術支援：Slack #ansible-support

---

<!-- _class: lead -->

# 謝謝

**祝您在 Ansible 自動化旅程上順利！** 🚀

**記得**：

- ✅ 實踐是最好的老師
- ✅ 先在 Staging 環境測試
- ✅ 遇到問題多查文件
- ✅ 善用社群資源

**Let's automate everything!** 🎯
