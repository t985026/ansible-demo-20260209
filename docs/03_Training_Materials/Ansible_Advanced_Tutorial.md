# Ansible 進階教學指南

本指南深入探討 Ansible 的進階功能，包括 Templates (Jinja2)、Handlers、任務控制 (Task Control)、檔案部署以及故障排除技巧。

## 1. Templates (Jinja2)

Ansible 使用 Jinja2 樣板語言來動態生成檔案。這對於配置檔案管理非常強大，允許您根據主機變數生成定製化的配置。

### 1.1 基本語法

- **變數**: 使用雙大括號 `{{ variable_name }}`。
- **控制結構**: 使用 `{% ... %}` (例如 loops 和 if/else)。
- **註釋**: 使用 `{# ... #}`。

### 1.2 範例：配置 Nginx

#### 1.2.1 定義變數

首先，在您的 Inventory、Group Vars 或 Host Vars 中定義所需的變數：

**方法一：在 Inventory 中定義**
```ini
[webservers]
web1.example.com http_port=80 server_name=web1.example.com enable_ssl=true
web2.example.com http_port=8080 server_name=web2.example.com enable_ssl=false
```

**方法二：在 Group Vars 中定義** (`group_vars/webservers.yml`)
```yaml
http_port: 80
server_name: "{{ ansible_hostname }}.example.com"
enable_ssl: true
ssl_cert_path: /etc/ssl/certs/server.crt
ssl_key_path: /etc/ssl/private/server.key
```

**方法三：在 Playbook 中定義**
```yaml
- hosts: webservers
  vars:
    http_port: 80
    server_name: example.com
    enable_ssl: true
    ssl_cert_path: /etc/ssl/certs/server.crt
    ssl_key_path: /etc/ssl/private/server.key
  tasks:
    # ...
```

**方法四：在 Role 的 defaults 中定義** (`roles/nginx/defaults/main.yml`)
```yaml
---
# Nginx Role 預設變數
# 這些變數擁有最低的優先權，可以被其他任何地方定義的變數覆寫

# HTTP 基本設定
http_port: 80
https_port: 443
server_name: "{{ ansible_fqdn }}"

# SSL 設定
enable_ssl: false
ssl_cert_path: /etc/ssl/certs/nginx-selfsigned.crt
ssl_key_path: /etc/ssl/private/nginx-selfsigned.key

# 效能調校
worker_processes: "{{ ansible_processor_vcpus | default(2) }}"
worker_connections: 1024

# 日誌設定
access_log_path: /var/log/nginx/access.log
error_log_path: /var/log/nginx/error.log
error_log_level: warn

# 應用程式設定
app_root: /var/www/html
index_files:
  - index.html
  - index.htm
  - index.php
```

**方法五：在 Role 的 vars 中定義** (`roles/nginx/vars/main.yml`)
```yaml
---
# Nginx Role 變數
# 這些變數擁有較高的優先權，通常用於不應被輕易覆寫的設定

# 套件名稱（依作業系統而定）
nginx_packages:
  Debian: nginx
  RedHat: nginx

nginx_service_name: nginx
nginx_config_path: /etc/nginx
nginx_sites_available: "{{ nginx_config_path }}/sites-available"
nginx_sites_enabled: "{{ nginx_config_path }}/sites-enabled"

# 必要的系統設定
nginx_user: www-data
nginx_group: www-data
```

#### 1.2.1.1 變數優先權順序

Ansible 的變數有明確的優先權順序（從低到高）：

1. **role defaults** (`defaults/main.yml`) - 最低優先權
2. **inventory file or script group vars**
3. **inventory group_vars/all**
4. **playbook group_vars/all**
5. **inventory group_vars/***
6. **playbook group_vars/***
7. **inventory file or script host vars**
8. **inventory host_vars/***
9. **playbook host_vars/***
10. **host facts / cached set_facts**
11. **play vars**
12. **play vars_prompt**
13. **play vars_files**
14. **role vars** (`vars/main.yml`)
15. **block vars** (僅在 block 內)
16. **task vars** (僅在 task 內)
17. **include_vars**
18. **set_facts / registered vars**
19. **role (and include_role) params**
20. **include params**
21. **extra vars** (`-e` 命令列參數) - 最高優先權

**實務建議：**
- 使用 `defaults/main.yml` 來設定可被覆寫的合理預設值
- 使用 `vars/main.yml` 來設定不應被更改的常數或路徑
- 使用 `group_vars` 和 `host_vars` 來針對不同環境客製化
- 使用 `extra vars` (`-e`) 來在執行時臨時覆寫變數

#### 1.2.1.2 建立變數檔案的目錄結構

標準的 Ansible 專案結構：

```
ansible-project/
├── ansible.cfg
├── inventory/
│   ├── production
│   └── staging
├── group_vars/
│   ├── all.yml              # 適用於所有主機
│   ├── webservers.yml       # 適用於 webservers 群組
│   └── databases.yml        # 適用於 databases 群組
├── host_vars/
│   ├── web1.example.com.yml # 特定主機的變數
│   └── web2.example.com.yml
├── roles/
│   └── nginx/
│       ├── defaults/
│       │   └── main.yml     # Role 預設變數
│       ├── vars/
│       │   └── main.yml     # Role 固定變數
│       ├── tasks/
│       │   └── main.yml
│       ├── templates/
│       │   └── nginx.conf.j2
│       └── handlers/
│           └── main.yml
└── site.yml                 # 主 Playbook
```

**建立範例：**

1. **建立 group_vars 檔案**
```bash
mkdir -p group_vars
cat > group_vars/webservers.yml <<EOF
---
http_port: 80
enable_ssl: true
server_name: "{{ inventory_hostname }}"
EOF
```

2. **建立 host_vars 檔案**
```bash
mkdir -p host_vars
cat > host_vars/web1.example.com.yml <<EOF
---
# web1 的特定設定
http_port: 8080
custom_settings:
  max_upload_size: 100M
  timeout: 300
EOF
```

3. **建立 Role defaults**
```bash
mkdir -p roles/nginx/defaults
cat > roles/nginx/defaults/main.yml <<EOF
---
# 可被覆寫的預設值
http_port: 80
worker_processes: auto
enable_ssl: false
EOF
```

#### 1.2.1.3 不同方式的執行與變數使用

以下展示如何在執行 Playbook 時使用不同來源的變數：

**1. 使用 Inventory 中的變數執行**

```bash
# Inventory 檔案: inventory/production
[webservers]
web1.example.com http_port=80
web2.example.com http_port=8080

# 執行 Playbook
ansible-playbook -i inventory/production site.yml
```

**2. 使用 Group Vars 執行**

```bash
# 變數檔案已在 group_vars/webservers.yml 中定義
# 直接執行即可，Ansible 會自動載入
ansible-playbook -i inventory site.yml

# 驗證變數是否正確載入
ansible webservers -i inventory -m debug -a "var=http_port"
```

**3. 使用命令列 Extra Vars 覆寫（最高優先權）**

```bash
# 單一變數覆寫
ansible-playbook -i inventory site.yml -e "http_port=9090"

# 多個變數覆寫
ansible-playbook -i inventory site.yml -e "http_port=9090 enable_ssl=true"

# 使用 JSON 格式
ansible-playbook -i inventory site.yml -e '{"http_port":9090,"enable_ssl":true}'

# 從檔案載入變數（YAML 或 JSON）
ansible-playbook -i inventory site.yml -e "@custom_vars.yml"
```

**4. 使用 vars_files 載入外部變數檔**

```yaml
# site.yml
---
- name: Configure Web Servers
  hosts: webservers
  vars_files:
    - vars/common.yml
    - vars/{{ env }}.yml  # 根據環境載入不同檔案
  tasks:
    # ...
```

```bash
# 執行時指定環境
ansible-playbook -i inventory site.yml -e "env=production"
```

**5. 使用 vars_prompt 互動式輸入**

```yaml
# site.yml
---
- name: Deploy Application
  hosts: webservers
  vars_prompt:
    - name: app_version
      prompt: "請輸入要部署的版本"
      private: no
      default: "1.0.0"
    
    - name: db_password
      prompt: "請輸入資料庫密碼"
      private: yes  # 不顯示輸入內容
  
  tasks:
    - name: Deploy version {{ app_version }}
      debug:
        msg: "Deploying version {{ app_version }}"
```

```bash
# 執行時會提示輸入
ansible-playbook -i inventory site.yml
```

**6. 限定執行範圍 (Limit)**

```bash
# 只在特定主機執行
ansible-playbook -i inventory site.yml --limit web1.example.com

# 只在特定群組執行
ansible-playbook -i inventory site.yml --limit webservers

# 排除特定主機
ansible-playbook -i inventory site.yml --limit 'all:!web2.example.com'

# 使用模式匹配
ansible-playbook -i inventory site.yml --limit 'web*.example.com'
```

**7. 使用 Tags 選擇性執行**

```yaml
# site.yml
---
- name: Configure Web Servers
  hosts: webservers
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
      tags:
        - nginx
        - packages
    
    - name: Configure Nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      tags:
        - nginx
        - config
    
    - name: Start Nginx
      service:
        name: nginx
        state: started
      tags:
        - nginx
        - service
```

```bash
# 只執行特定 tag
ansible-playbook -i inventory site.yml --tags "config"

# 執行多個 tags
ansible-playbook -i inventory site.yml --tags "config,service"

# 跳過特定 tags
ansible-playbook -i inventory site.yml --skip-tags "packages"

# 列出所有可用的 tags
ansible-playbook -i inventory site.yml --list-tags
```

**8. 檢查模式與差異比對**

```bash
# Dry run（不實際執行，只顯示會改變什麼）
ansible-playbook -i inventory site.yml --check

# 顯示檔案變更的差異
ansible-playbook -i inventory site.yml --check --diff

# 實際執行但顯示差異
ansible-playbook -i inventory site.yml --diff
```

**9. 逐步執行（Step Mode）**

```bash
# 每個 task 執行前都會詢問
ansible-playbook -i inventory site.yml --step

# 回應選項:
# y: 執行此 task
# n: 跳過此 task  
# c: 繼續執行剩餘所有 tasks
```

**10. 從特定 Task 開始執行**

```yaml
# site.yml
tasks:
  - name: Task 1
    debug: msg="First task"
  
  - name: Configure Application
    debug: msg="Second task"
  
  - name: Task 3
    debug: msg="Third task"
```

```bash
# 從特定 task 開始執行
ansible-playbook -i inventory site.yml --start-at-task="Configure Application"
```

**11. 完整範例：組合多種選項**

```bash
# 生產環境部署範例
ansible-playbook \
  -i inventory/production \           # 使用生產環境 inventory
  site.yml \                          # Playbook 檔案
  --limit webservers \                # 只在 webservers 群組執行
  --tags "config,service" \           # 只執行配置和服務相關 tasks
  -e "env=production" \               # 指定環境變數
  -e "@vars/production_override.yml" \ # 載入額外變數檔
  --diff \                            # 顯示變更差異
  -v                                  # 顯示詳細輸出
```

**12. 使用 ansible.cfg 設定預設行為**

```ini
# ansible.cfg
[defaults]
inventory = ./inventory/production
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

```bash
# 有了 ansible.cfg 後，可以簡化命令
ansible-playbook site.yml  # 會自動使用設定檔中的 inventory
```

#### 1.2.2 建立 Jinja2 樣板

假設我們有一個 `nginx.conf.j2` 樣板（存放在 `templates/` 目錄中）：

```nginx
# Nginx Configuration - Generated by Ansible
# Last updated: {{ ansible_date_time.iso8601 }}
# Managed host: {{ ansible_hostname }}

server {
    # HTTP 監聽埠
    listen {{ http_port }};
    server_name {{ server_name }};

    # 網站根目錄
    root /var/www/html;
    index index.html index.htm;

    # 條件式 SSL 配置
    {% if enable_ssl %}
    # HTTPS 配置
    listen 443 ssl;
    ssl_certificate {{ ssl_cert_path }};
    ssl_certificate_key {{ ssl_key_path }};
    
    # SSL 協定設定
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    {% endif %}

    # 日誌配置
    access_log /var/log/nginx/{{ server_name }}_access.log;
    error_log /var/log/nginx/{{ server_name }}_error.log;

    # Location 區塊
    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### 1.2.3 在 Playbook 中使用 Template 模組

```yaml
---
- name: Configure Nginx Web Servers
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    server_name: "{{ ansible_fqdn }}"
    enable_ssl: true
    ssl_cert_path: /etc/ssl/certs/server.crt
    ssl_key_path: /etc/ssl/private/server.key

  tasks:
    - name: Deploy Nginx configuration from template
      template:
        src: templates/nginx.conf.j2      # 來源樣板檔案
        dest: /etc/nginx/sites-available/default  # 目標路徑
        owner: root                        # 檔案擁有者
        group: root                        # 檔案群組
        mode: '0644'                       # 檔案權限
        backup: yes                        # 覆寫前先備份
        validate: 'nginx -t -c %s'        # 部署前驗證配置
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

**Template 模組參數說明：**
- `src`: 樣板檔案路徑（相對於 Playbook 的 `templates/` 目錄）
- `dest`: 目標主機上的檔案路徑
- `owner/group`: 設定檔案的擁有者和群組
- `mode`: 設定檔案權限（八進位格式）
- `backup`: 若檔案已存在，部署前先建立備份（附加時間戳記）
- `validate`: 部署前執行驗證命令，`%s` 會被替換為暫存檔路徑

### 1.3 常用 Filters

Jinja2 提供了多種過濾器（Filters）來轉換和處理數據。

#### 1.3.1 預設值處理

```yaml
# 如果變數未定義或為空，使用預設值
{{ my_var | default('default_value') }}

# 只在變數為 None 時使用預設值（空字串不算）
{{ my_var | default('default_value', boolean=True) }}

# 實際範例
server_name: {{ custom_server_name | default(ansible_hostname) }}
```

#### 1.3.2 資料格式轉換

```yaml
# 轉換為 JSON 格式（適合配置檔案或 API）
{{ my_dict | to_json }}
{{ my_list | to_nice_json }}  # 美化格式（縮排）

# 轉換為 YAML 格式
{{ my_dict | to_yaml }}
{{ my_list | to_nice_yaml }}

# 範例
config_data: {{ app_config | to_json }}
```

#### 1.3.3 字串處理

```yaml
# 大小寫轉換
{{ server_name | upper }}        # 全部大寫
{{ server_name | lower }}        # 全部小寫
{{ server_name | capitalize }}   # 首字母大寫
{{ server_name | title }}        # 每個單字首字母大寫

# 字串替換
{{ path | replace('/old/', '/new/') }}

# 實際範例
environment: {{ env_name | upper }}  # 輸出: PRODUCTION
```

#### 1.3.4 列表與字典處理

```yaml
# 列表操作
{{ my_list | length }}           # 取得列表長度
{{ my_list | first }}            # 取得第一個元素
{{ my_list | last }}             # 取得最後一個元素
{{ my_list | unique }}           # 去除重複項
{{ my_list | sort }}             # 排序
{{ my_list | join(', ') }}       # 用指定分隔符號連接

# 字典操作
{{ my_dict | dict2items }}       # 字典轉列表
{{ my_dict.keys() | list }}      # 取得所有鍵

# 範例：產生以逗號分隔的伺服器列表
servers: {{ web_servers | join(', ') }}
```

#### 1.3.5 數學與類型轉換

```yaml
# 數學運算
{{ ansible_processor_cores | int * 2 }}
{{ memory_gb | float / 1024 }}

# 類型轉換
{{ port_number | int }}
{{ price | float }}
{{ is_enabled | bool }}
{{ server_count | string }}

# 範例
worker_processes: {{ ansible_processor_vcpus | default(2) | int }}
```

#### 1.3.6 檔案路徑處理

```yaml
# 路徑操作
{{ file_path | basename }}       # 取得檔案名稱
{{ file_path | dirname }}        # 取得目錄路徑
{{ file_path | realpath }}       # 取得絕對路徑
{{ file_path | splitext }}       # 分離副檔名

# 範例
log_file: {{ app_path | basename }}.log
```

#### 1.3.7 進階範例：組合使用

```yaml
# 在樣板中組合多個 Filter
{% set db_servers = groups['database'] | map('extract', hostvars, 'ansible_default_ipv4') | map(attribute='address') | list %}

database_hosts:
{% for ip in db_servers %}
  - {{ ip }}
{% endfor %}

# 條件式預設值
backend_port: {{ custom_port | default(8080) | int }}
max_connections: {{ max_conn | default(ansible_processor_vcpus | int * 100) }}

# 複雜的字串處理
app_name: {{ service_name | lower | replace(' ', '_') | truncate(20) }}
```

---

## 2. Handlers

Handlers 是特殊的 Task，只有在被其他 Task "通知 (notify)" 且該 Task 狀態為 "Changed" 時才會執行。它們通常用於重啟服務或重新加載配置。

### 2.1 定義與使用

```yaml
tasks:
  - name: Update configuration file
    template:
      src: myapp.conf.j2
      dest: /etc/myapp/myapp.conf
    notify: Restart MyApp  # 通知 Handler

handlers:
  - name: Restart MyApp  # Handler 名稱必須與 notify 一致
    service:
      name: myapp
      state: restarted
```

### 2.2 特性

- **執行時機**: 預設情況下，Handlers 會在 Playbook 的所有 Tasks 執行完畢後才執行。
- **多次通知，一次執行**: 即使 Handler 被通知多次，它在一次 Play 中只會執行一次。

---

## 3. Implementing Task Control

Ansible 提供了多種控制任務執行流程的機制。

### 3.1 條件執行 (`when`)

使用 `when` 來決定是否執行某個 Task。

```yaml
- name: Install apache on Debian
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"

- name: Install httpd on RedHat
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"
```

### 3.2 迴圈 (`loop`)

使用 `loop` 重複執行任務。

```yaml
- name: Add several users
  user:
    name: "{{ item.name }}"
    state: present
    groups: "{{ item.groups }}"
  loop:
    - { name: 'alice', groups: 'wheel' }
    - { name: 'bob', groups: 'root' }
```

### 3.3 區塊 (`block`) 與錯誤處理 (`rescue`, `always`)

`block` 可以將多個 Tasks 組合在一起，並支援錯誤處理。

```yaml
- name: Attempt to update and restart
  block:
    - name: Update application
      command: /opt/app/update.sh
    - name: Restart application
      service:
        name: myapp
        state: restarted
  rescue:
    - name: Rollback update
      command: /opt/app/rollback.sh
      when: ansible_failed_task.name == 'Update application'
  always:
    - name: Send notification
      debug:
        msg: "Deployment attempt completed"
```

---

## 4. Deploying Files to Managed Hosts

Ansible 提供了多種模組來管理檔案。

### 4.1 `copy` 模組

用於將控制節點上的靜態檔案複製到受管主機。

```yaml
- name: Copy configuration file
  copy:
    src: files/myconfig.conf
    dest: /etc/myapp/myconfig.conf
    owner: root
    group: root
    mode: '0644'
```

### 4.2 `template` 模組

如前所述，用於部署動態生成的檔案。

### 4.3 `fetch` 模組

用於從受管主機抓取檔案到控制節點 (與 `copy` 相反)。

```yaml
- name: Fetch logs from remote host
  fetch:
    src: /var/log/myapp.log
    dest: backups/logs/
    flat: yes
```

---

## 5. Troubleshooting Ansible

當 Playbook 執行失敗或不如預期時，以下技巧有助於排查問題。

### 5.1 Verbose Mode

增加輸出的詳細程度。

- `-v`: 顯示簡單的結果。
- `-vv`: 顯示輸入參數。
- `-vvv`: 顯示與受管主機的連線資訊。
- `-vvvv`: 連線除錯模式 (極詳細)。

```bash
ansible-playbook -i inventory site.yml -vvv
```

### 5.2 `debug` 模組

在執行過程中印出變數值或訊息。

```yaml
- name: Print variable value
  debug:
    var: my_variable

- name: Print message
  debug:
    msg: "System OS is {{ ansible_os_family }}"
```

### 5.3 Syntax Check & Dry Run

- **語法檢查**:

    ```bash
    ansible-playbook site.yml --syntax-check
    ```

- **模擬執行 (Dry Run)**: 顯示會發生什麼改變，但不實際執行。

    ```bash
    ansible-playbook site.yml --check
    ```

- **顯示差異**: 配合 `--check` 使用，顯示檔案修改的差異。

    ```bash
    ansible-playbook site.yml --check --diff
    ```

### 5.4 常見問題

1. **連線失敗**: 檢查 SSH 金鑰、防火牆、`ansible_user`。
2. **權限不足**: 確保使用了 `become: yes` (sudo)。
3. **變數未定義**: 檢查變數命名拼寫，確認變數範圍 (Scope)。
4. **YAML 縮排錯誤**: YAML 對縮排非常敏感，務必保持一致 (通常是 2 個空白)。
