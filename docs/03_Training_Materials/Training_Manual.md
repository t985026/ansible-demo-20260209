# Ansible 自動化部署與加固專案 - 教育訓練手冊

| 課程資訊 | 內容 |
| :--- | :--- |
| **課程名稱** | Ansible 自動化部署與系統加固實務訓練 |
| **文件編號** | TRAIN-20260129-v1.0 |
| **版本** | v1.0 |
| **訓練時數** | 8 小時 (含實作) |
| **適用對象** | 系統管理員、DevOps 工程師、維運人員 |
| **更新日期** | 2026-01-29 |

---

## 課程目標 (Learning Objectives)

完成本課程後，學員將能夠：

1. **理解 Ansible 基礎概念**：掌握 Infrastructure as Code (IaC) 核心理念
2. **執行自動化部署**：獨立執行網頁伺服器的標準化部署
3. **實施系統加固**：應用企業級安全基線進行系統強化
4. **處理日常維運**：使用 Ansible 進行設定變更與故障排除
5. **保護機敏資料**：正確使用 Ansible Vault 管理密碼與金鑰

---

## 課程大綱 (Course Outline)

### 第一部分：Ansible 基礎概念 (1.5 小時)

#### 1.1 什麼是 Infrastructure as Code (IaC)?

**傳統運維的挑戰**：

- ✗ 手動設定容易出錯
- ✗ 環境不一致導致「我的電腦可以跑」問題
- ✗ 缺乏版本控制與審計軌跡
- ✗ 新人上手困難，知識依賴老手

**IaC 的優勢**：

- ✓ 自動化、可重複執行
- ✓ 配置即程式碼，納入 Git 版本管理
- ✓ 執行前可審查 (Code Review)
- ✓ 新環境快速複製

#### 1.2 Ansible 核心元件介紹

```text
┌─────────────────┐
│ Control Node    │ ← 你的筆電或跳板機
│ (Ansible 安裝處) │
└────────┬────────┘
         │ SSH Connection
         ▼
┌─────────────────────────────────┐
│  Managed Nodes (目標伺服器群)    │
│  ┌──────┐ ┌──────┐ ┌──────┐    │
│  │Web-01│ │Web-02│ │Web-03│    │
│  └──────┘ └──────┘ └──────┘    │
└─────────────────────────────────┘
```

**關鍵術語**：

- **Control Node**：執行 Ansible 指令的機器
- **Managed Node**：被管理的目標主機
- **Inventory**：主機清單 (列出所有要管理的伺服器)
- **Playbook**：工作腳本 (定義要執行的任務)
- **Module**：功能模組 (如 `apt`、`file`、`service` 等)

#### 1.3 Ansible 工作原理

1. 讀取 Inventory 檔案，取得目標主機清單
2. 透過 SSH 連線至 Managed Nodes
3. 將 Python 模組推送至遠端主機
4. 執行任務並回傳結果
5. **無需在目標主機安裝 Agent**

#### 1.4 Ansible 的冪等性 (Idempotency)

**重要概念**：多次執行相同的 Playbook，結果應該相同。

**範例**：

```yaml
# 這個任務具有冪等性
- name: 確保 Nginx 已安裝
  apt:
    name: nginx
    state: present
```

- 第一次執行：安裝 Nginx → **Changed**
- 第二次執行：已安裝，略過 → **OK (No Change)**

---

### 第二部分：專案架構解析 (1.5 小時)

#### 2.1 專案目錄結構深度導覽

```text
Ansible/project/
├── docs/                       # 📚 專案文件中心
│   ├── 01_PRD.md              # 產品需求規格書
│   ├── 02_Technical_Architecture.md  # 技術架構設計
│   ├── 03_Operation_Manual.md # 營運操作手冊
│   └── Training_Manual.md     # 本教育訓練手冊
│
├── inventory/                  # 🎯 環境定義層
│   ├── production             # 正式環境主機清單
│   └── staging                # 測試環境主機清單
│
├── group_vars/                 # ⚙️ 變數配置層
│   ├── all.yml                # 全域變數 (所有主機共用)
│   ├── webservers.yml         # Web Server 群組專屬變數
│   └── security_targets.yml   # 加固目標群組專屬變數
│
├── web_server_setup.yml        # 🚀 執行層：網頁部署邏輯
└── system_hardening.yml        # 🔒 執行層：系統加固邏輯
```

#### 2.2 Inventory 設計哲學

**功能性分群策略**：

```ini
# inventory/production
[webservers]
web-prod-01 ansible_host=10.1.1.10
web-prod-02 ansible_host=10.1.1.11

[security_targets]
web-prod-01
web-prod-02
db-prod-01 ansible_host=10.1.1.20
```

**為什麼要分群？**

- 一台主機可以屬於多個群組
- 不同群組可以套用不同變數
- 執行任務時可以精準鎖定目標

**環境隔離機制**：

```bash
# 測試環境
ansible-playbook -i inventory/staging web_server_setup.yml

# 正式環境
ansible-playbook -i inventory/production web_server_setup.yml
```

#### 2.3 變數管理策略

**變數優先權 (由低到高)**：

1. `group_vars/all.yml` ← 最低優先級
2. `group_vars/webservers.yml`
3. Inventory 檔案中的 host_vars
4. Playbook 中的 vars (不建議)

**實例**：

```yaml
# group_vars/all.yml
admin_user: ansible_admin  # 預設管理員帳號

# group_vars/webservers.yml
admin_user: webmaster      # Web Server 群組覆蓋預設值
web_root: /var/www/html
```

---

### 第三部分：實作演練 - Web Server 部署 (2 小時)

#### 3.1 環境檢查 (Pre-flight Check)

**步驟 1：檢查 Ansible 版本**

```bash
ansible --version
```

**預期輸出**：

```
ansible 2.9.x (或更高版本)
  config file = /etc/ansible/ansible.cfg
  python version = 3.8.x
```

**步驟 2：測試 SSH 連通性**

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

> **[故障排除]** 若出現 `UNREACHABLE`：
>
> 1. 檢查 Inventory 中的 IP 是否正確
> 2. 確認 SSH Key 已部署：`ssh-copy-id user@target-host`
> 3. 手動測試連線：`ssh user@target-host`

#### 3.2 Playbook 解析：`web_server_setup.yml`

```yaml
---
- name: 自動化部署與配置 Nginx Web Server
  hosts: webservers  # 目標群組
  become: yes        # 使用 sudo 權限
  
  tasks:
    - name: 安裝 Nginx 套件
      apt:
        name: nginx
        state: present
        update_cache: yes
    
    - name: 建立 Web 管理員帳號
      user:
        name: "{{ admin_user }}"  # 從變數讀取
        state: present
        shell: /bin/bash
    
    - name: 部署預設網頁
      copy:
        content: |
          <html>
          <body>
            <h1>Welcome to Automated Deployment</h1>
          </body>
          </html>
        dest: "{{ web_root }}/index.html"
        owner: "{{ admin_user }}"
        mode: '0644'
    
    - name: 確保 Nginx 服務啟動
      service:
        name: nginx
        state: started
        enabled: yes
```

**重點說明**：

- `{{ admin_user }}`：Jinja2 變數語法，從 `group_vars` 讀取
- `become: yes`：以 sudo 權限執行
- `state: present`：確保套件已安裝 (冪等性)

#### 3.3 執行部署

**測試環境執行**：

```bash
ansible-playbook -i inventory/staging web_server_setup.yml
```

**正式環境執行**：

```bash
# 加上 --check 進行預演 (Dry Run)
ansible-playbook -i inventory/production web_server_setup.yml --check

# 確認無誤後正式執行
ansible-playbook -i inventory/production web_server_setup.yml
```

#### 3.4 驗證部署結果

**方法 1：使用 curl 測試**

```bash
curl http://web-staging-01
```

**方法 2：使用 Ansible Ad-hoc 指令**

```bash
ansible -i inventory/staging webservers -m shell -a "systemctl status nginx"
```

---

### 第四部分：實作演練 - 系統加固 (2 小時)

#### 4.1 安全基線概述

企業級系統加固包含：

- ✓ 禁止 Root 直接登入
- ✓ 強制使用 SSH Key 認證
- ✓ 設定 SSH 閒置逾時
- ✓ 啟用防火牆 (UFW)
- ✓ 安裝入侵防禦系統 (Fail2Ban)

#### 4.2 Playbook 解析：`system_hardening.yml`

```yaml
---
- name: 系統安全性加固 (CIS Benchmark 參考)
  hosts: security_targets
  become: yes
  
  tasks:
    # Task 1: SSH 安全設定
    - name: 禁止 Root 登入
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
      notify: restart sshd
    
    - name: 設定 SSH 閒置逾時 (5分鐘)
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^ClientAliveInterval'
        line: 'ClientAliveInterval 300'
      notify: restart sshd
    
    # Task 2: 防火牆設定
    - name: 安裝 UFW 防火牆
      apt:
        name: ufw
        state: present
    
    - name: 允許 SSH 連線
      ufw:
        rule: allow
        port: '22'
        proto: tcp
    
    - name: 啟用 UFW
      ufw:
        state: enabled
  
  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted
```

**Handler 機制說明**：

- `notify: restart sshd`：當設定檔變更時，觸發重啟服務
- Handler 只會在所有 Task 執行完後執行一次 (避免多次重啟)

#### 4.3 執行加固 (Critical Section)

> **⚠️ 警告：請勿在未建立備用連線的情況下執行加固！**
>
> 建議步驟：
>
> 1. 確保你有 Console 存取權 (VNC/IPMI)
> 2. 開啟第二個 SSH 視窗保持連線
> 3. 執行加固腳本
> 4. 在第三個視窗測試新連線是否正常
> 5. 若無法連線，立即使用第二個視窗回退變更

**執行指令**：

```bash
ansible-playbook -i inventory/staging system_hardening.yml
```

#### 4.4 加固後驗證

**檢查 SSH 設定**：

```bash
ansible -i inventory/staging security_targets -m shell \
  -a "grep PermitRootLogin /etc/ssh/sshd_config"
```

**檢查防火牆狀態**：

```bash
ansible -i inventory/staging security_targets -m shell \
  -a "ufw status"
```

---

### 第五部分：日常維運操作 (1.5 小時)

#### 5.1 變數調整 SOP

**情境**：需要變更 Web Root 路徑。

**錯誤做法** ✗：

```bash
# 直接 SSH 到主機手動改
ssh web-01
sudo vi /etc/nginx/sites-enabled/default
```

**正確做法** ✓：

```bash
# 1. 修改變數檔案
vi group_vars/webservers.yml
# 將 web_root: /var/www/html 改為 web_root: /var/www/myapp

# 2. 執行 Playbook 重新套用
ansible-playbook -i inventory/production web_server_setup.yml

# 3. Git 版本控制
git add group_vars/webservers.yml
git commit -m "Change web root to /var/www/myapp"
git push
```

**為什麼要這樣做？**

- 保留變更歷史 (Git Commit)
- 確保所有主機一致性
- 其他同事可以追蹤變更原因

#### 5.2 Ad-hoc 指令實戰

**情境 1：快速檢查磁碟使用率**

```bash
ansible -i inventory/production all -m shell -a "df -h /"
```

**情境 2：批量重啟服務**

```bash
ansible -i inventory/production webservers -m service \
  -a "name=nginx state=restarted" --become
```

**情境 3：收集系統資訊**

```bash
ansible -i inventory/production all -m setup
```

#### 5.3 常見故障排除

| 錯誤訊息 | 原因 | 解決方案 |
| :--- | :--- | :--- |
| `UNREACHABLE! => {"msg": "Failed to connect..."}` | SSH 連線失敗 | 1. `ping` IP<br>2. `telnet IP 22`<br>3. 檢查 SSH Key |
| `Missing sudo password` | 目標主機需要 sudo 密碼 | 執行時加上 `-K`：<br>`ansible-playbook ... -K` |
| `apt: E: Could not get lock` | 有其他 apt 程序在執行 | `ps aux | grep apt`<br>等待背景更新完成 |
| `Permission denied (publickey)` | SSH Key 未部署 | `ssh-copy-id user@host` |

---

### 第六部分：機敏資料管理 (1 小時)

#### 6.1 為什麼需要 Ansible Vault?

**問題情境**：

```yaml
# group_vars/all.yml (未加密)
db_password: SuperSecret123  # ✗ 明碼存放，推 Git 會外洩
api_key: abc123xyz           # ✗ 任何人都能看到
```

**解決方案**：使用 Ansible Vault 加密整個檔案。

#### 6.2 加密變數檔案

**步驟 1：加密檔案**

```bash
ansible-vault encrypt group_vars/all.yml
# 輸入加密密碼 (Vault Password)
```

**步驟 2：查看加密後的內容**

```bash
cat group_vars/all.yml
```

**輸出範例**：

```
$ANSIBLE_VAULT;1.1;AES256
66386439653865343534...
```

**步驟 3：編輯加密檔案**

```bash
ansible-vault edit group_vars/all.yml
# 會要求輸入密碼，然後開啟編輯器
```

#### 6.3 執行使用加密變數的 Playbook

```bash
# 執行時要求輸入 Vault 密碼
ansible-playbook -i inventory/production web_server_setup.yml --ask-vault-pass

# 或使用密碼檔案 (更適合 CI/CD)
echo "MyVaultPassword" > .vault_pass
chmod 600 .vault_pass
ansible-playbook ... --vault-password-file .vault_pass
```

> **[重要]** `.vault_pass` 檔案務必加入 `.gitignore`！

#### 6.4 產生密碼雜湊

**情境**：建立 Linux 使用者時，需要設定密碼。

**錯誤做法** ✗：

```yaml
- name: 建立使用者
  user:
    name: john
    password: "mypassword"  # ✗ 明碼密碼無法使用
```

**正確做法** ✓：

```bash
# 產生 SHA-512 雜湊
ansible all -i localhost, -m debug \
  -a "msg={{ 'MyPassword123' | password_hash('sha512') }}"
```

**輸出**：

```
$6$rounds=656000$YourSaltHere$HashValue...
```

**應用**：

```yaml
- name: 建立使用者 (使用雜湊密碼)
  user:
    name: john
    password: "$6$rounds=656000$YourSaltHere$HashValue..."
```

---

### 第七部分：進階主題與最佳實踐 (0.5 小時)

#### 7.1 Version Control 整合

```bash
# 初始化 Git Repository
cd /path/to/ansible/project
git init
git add .
git commit -m "Initial Ansible project"

# .gitignore 範例
*.retry
.vault_pass
inventory/production  # 若包含敏感 IP
```

#### 7.2 CI/CD 整合

**GitLab CI 範例**：

```yaml
# .gitlab-ci.yml
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
  when: manual  # 需手動觸發
  only:
    - main
```

#### 7.3 效能優化技巧

**平行執行**：

```yaml
# ansible.cfg
[defaults]
forks = 10  # 同時對 10 台主機執行
```

**SSH 連線複用**：

```yaml
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

---

## 實作練習題 (Hands-on Lab)

### 練習 1：基礎部署 (20 分鐘)

**任務**：

1. 修改 `group_vars/webservers.yml`，將網站標題改為「Welcome to [你的名字] Lab」
2. 執行 Playbook 部署至 Staging 環境
3. 使用 `curl` 驗證變更是否生效

### 練習 2：安全加固 (30 分鐘)

**任務**：

1. 在 `system_hardening.yml` 中新增一個 Task：
   - 安裝 `fail2ban` 套件
   - 確保 `fail2ban` 服務啟動
2. 執行 Playbook
3. 驗證 `fail2ban` 是否正常運作

**提示**：

```yaml
- name: 安裝 Fail2Ban
  apt:
    name: fail2ban
    state: present
```

### 練習 3：Vault 實戰 (20 分鐘)

**任務**：

1. 建立新檔案 `group_vars/secrets.yml`，內容：

   ```yaml
   db_password: MySecretPassword
   ```

2. 使用 `ansible-vault encrypt` 加密此檔案
3. 建立簡單 Playbook 讀取並顯示此變數
4. 執行時使用 `--ask-vault-pass`

---

## 課後評量 (Assessment)

### 選擇題

**Q1. Ansible 的主要優勢不包括以下哪項？**

- A. 無需在目標主機安裝 Agent
- B. 使用 YAML 語法撰寫
- C. 需要複雜的資料庫設定
- D. 支援冪等性操作

<details>
<summary>答案</summary>
C. 需要複雜的資料庫設定 (Ansible 不需要資料庫)
</details>

**Q2. 若要隔離測試與正式環境，應該使用什麼機制？**

- A. 不同的 Playbook 檔案
- B. 不同的 Inventory 檔案
- C. 不同的模組
- D. 不同的 Ansible 版本

<details>
<summary>答案</summary>
B. 不同的 Inventory 檔案
</details>

### 實作題

**Q3. 請寫出檢查所有 Web Server 的 Nginx 版本的指令。**

<details>
<summary>答案</summary>

```bash
ansible -i inventory/production webservers -m shell -a "nginx -v"
```

</details>

---

## 參考資源 (References)

- **Ansible 官方文件**：<https://docs.ansible.com/>
- **Ansible Best Practices**：<https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html>
- **CIS Benchmark (安全基線)**：<https://www.cisecurity.org/cis-benchmarks>
- **專案內部文件**：
  - [01_PRD.md](01_PRD.md) - 產品需求規格書
  - [02_Technical_Architecture.md](02_Technical_Architecture.md) - 技術架構
  - [03_Operation_Manual.md](03_Operation_Manual.md) - 操作手冊

---

## 附錄 A：常用指令速查表

```bash
# === 基本測試 ===
ansible all -m ping                          # 測試連線
ansible all -m setup                         # 收集系統資訊

# === Playbook 執行 ===
ansible-playbook playbook.yml                # 基本執行
ansible-playbook playbook.yml --check        # 預演模式 (Dry Run)
ansible-playbook playbook.yml -v             # Verbose 輸出
ansible-playbook playbook.yml --step         # 逐步執行

# === Vault 管理 ===
ansible-vault encrypt file.yml               # 加密
ansible-vault decrypt file.yml               # 解密
ansible-vault edit file.yml                  # 編輯加密檔案
ansible-vault view file.yml                  # 查看加密檔案

# === Ad-hoc 指令 ===
ansible all -a "uptime"                      # 執行 Shell 指令
ansible all -m apt -a "name=vim state=present" --become  # 安裝套件
```

---

## 附錄 B：疑難雜症 FAQ

**Q: 執行 Playbook 時速度很慢怎麼辦？**
A: 檢查以下項目：

1. 啟用 SSH Pipelining (`ansible.cfg`)
2. 增加 Forks 數量
3. 確認 DNS 解析正常

**Q: 如何只執行 Playbook 中的特定 Task？**
A: 使用 Tags：

```yaml
- name: 安裝 Nginx
  apt:
    name: nginx
  tags: install

# 執行時指定
ansible-playbook playbook.yml --tags install
```

**Q: 如何在執行前確認會影響哪些主機？**
A: 使用 `--list-hosts`：

```bash
ansible-playbook -i inventory/production web_server_setup.yml --list-hosts
```

---

**課程結束！祝學習順利！** 🎓
