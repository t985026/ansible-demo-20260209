# 03. 系統營運操作手冊 (Operation Manual)

| 文件資訊 | 內容 |
| :--- | :--- |
| **適用對象** | 系統管理員 (SysAdmin), 營運工程師 (Ops) |
| **文件編號** | SOP-20260116-v1.0 |
| **更新日期** | 2026-01-16 |

## 1. 環境準備 (Prerequisites)

在執行任何自動化作業前，請確認控制節點 (Control Node) 狀態：

1. **Ansible 版本檢查**：

    ```bash
    ansible --version
    # 建議版本：2.9 以上
    ```

2. **SSH 連通性測試**：

    ```bash
    ansible -i inventory/staging all -m ping
    # Ensure result shows "pong"
    ```

## 2. 標準作業程序 (SOP)

### SOP-01: 部署/更新網頁伺服器

**情境**：新主機上線或網頁設定檔更新。

1. **確認目標環境**：決定是 Staging 或 Production。
2. **執行 Playbook**：

    ```bash
    # For Staging
    ansible-playbook -i inventory/staging web_server_setup.yml

    # For Production
    ansible-playbook -i inventory/production web_server_setup.yml
    ```

3. **驗證服務狀態**：確認 Nginx 是否正常回應。

### SOP-02: 執行系統安全性加固

**情境**：定期安全性合規檢查或新機初始化。

> **[CAUTION] 注意事項**
> 此作業將會修改 SSH 設定並啟用防火牆。請務必確保您已擁有具備 sudo 權限的備用連線方式，以免遭鎖定於系統外。

1. **執行 Playbook**：

    ```bash
    ansible-playbook -i inventory/production system_hardening.yml
    ```

2. **驗證 SSH 存取**：開新 Terminal 視窗嘗試登入，確認連線正常。

## 3. 日常維護與變數調整

若需調整配置，請**不要**直接修改 Playbook，應修改 `group_vars`：

- **修改管理員帳號**：編輯 `group_vars/all.yml` -> `admin_user`。
- **修改網站根目錄**：編輯 `group_vars/webservers.yml` -> `web_root`。

## 4. 故障排除指引 (Troubleshooting)

| 錯誤訊息 | 可能原因 | 解決方案 |
| :--- | :--- | :--- |
| `UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh..."}` | SSH 連線失敗 | 1. 檢查 IP 是否正確 <br> 2. 確認 SSH Key 是否已部署 (`ssh-copy-id`) |
| `Missing sudo password` | 執行帳號 sudo 需要密碼 | 執行指令時加上 `-K` 參數： `ansible-playbook ... -K` |
| `apt: E: Could not get lock /var/lib/dpkg/lock` | 有其他 apt 程序在背景執行 | 等待背景更新完成，或手動檢查製程 (`ps aux | grep apt`) |

## 5. 災難復原 (Disaster Recovery)

若部署發生嚴重錯誤導致服務中斷：

1. **Nginx 設定錯誤**：Playbook 具備備份機制，可至目標主機 `/etc/nginx/nginx.conf.bak` 找回舊設定。
2. **SSH 無法連線**：需透過主機商 Console (VNC) 登入，檢查 `/etc/ssh/sshd_config` 或停用 UFW (`sudo ufw disable`)。

## 6. 機敏資料管理 (Sensitive Data Management)

本專案強烈建議使用 **Ansible Vault** 來保護密碼與金鑰。

### 6.1 加密變數檔案

若要加密 `group_vars/all.yml` (含有帳號設定)：

```bash
ansible-vault encrypt group_vars/all.yml
# 輸入加密密碼
```

### 6.2 執行加密後的 Playbook

當變數檔案被加密後，執行 Playbook 需加上 `--ask-vault-pass`：

```bash
ansible-playbook -i inventory/production web_server_setup.yml --ask-vault-pass
```

### 6.3 產生密碼雜湊 (Password Hash)

請勿在檔案中使用明碼密碼。使用以下指令產生 Linux 系統可用的 SHA-512 雜湊：

```bash
ansible all -i localhost, -m debug -a "msg={{ '您的密碼' | password_hash('sha512') }}"
```

將輸出的 `$6$...` 字串複製到 `group_vars` 中。

## 7. 輔助工具 (Tools)

本專案附帶了維運輔助腳本，位於 `tools/` 目錄。

### 7.1 網路連線檢查 (`network_check.sh`)

批量檢查目標主機的 SSH (22) 與 Web (80) 連通性。

**使用方式**：

```bash
cd tools/
bash network_check.sh ../inventory/production
```

**輸出範例**：

```text
Checking Host: 192.168.1.10
  [SSH] Port 22: OPEN (OK)
  [WEB] Port 80: CLOSED/TIMEOUT (FAIL)
```
