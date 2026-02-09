# Killercoda Ansible Demo 快速啟動指令集

## 完整執行流程（複製貼上）

```bash
# === 步驟 1: 安裝 Ansible ===
apt update && apt install ansible -y

# === 步驟 2: 設定 SSH 免密碼登入 ===
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
ssh-copy-id -o StrictHostKeyChecking=no node01

# === 步驟 3: 下載專案（替換為您的 Git URL）===
git clone https://github.com/t985026/ansible-demo-20260209.git
cd ansible-demo-20260209/demo

# === 步驟 4: 驗證環境 ===
chmod +x verify_environment.sh
./verify_environment.sh

# === 步驟 5: 執行部署 ===
chmod +x deploy.sh
./deploy.sh

# === 步驟 6: 驗證結果 ===
curl http://node01
ssh node01 "systemctl status nginx"
```

## 單行快速啟動（適合 Killercoda）

```bash
apt update && apt install ansible git -y && ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa && ssh-copy-id -o StrictHostKeyChecking=no node01 && git clone https://github.com/t985026/ansible-demo-20260209.git && cd ansible-demo-20260209/demo && chmod +x deploy.sh && ./deploy.sh
```

## 疑難排解

### SSH 連線問題

```bash
# 測試 SSH
ssh node01 "hostname"

# 重新配置 SSH 金鑰
rm -rf ~/.ssh/id_rsa*
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
ssh-copy-id -o StrictHostKeyChecking=no node01
```

### Ansible 連線測試

```bash
ansible -i inventory/hosts all -m ping
ansible -i inventory/hosts all -m shell -a "hostname"
```

### 手動執行 Playbook（調試模式）

```bash
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml -vvv
```

### 清理重新開始

```bash
ssh node01 "apt remove nginx -y && rm -rf /var/www/demo /var/log/nginx_custom && userdel -r webadmin"
```

## 教學建議流程

1. **基礎介紹** (5 分鐘)
   - 說明 Ansible 架構
   - 展示 inventory 檔案

2. **連線測試** (5 分鐘)
   - 執行 ping 模組
   - 說明 SSH 免密碼登入原理

3. **Playbook 解析** (10 分鐘)
   - 逐行解釋 tasks/web_server_setup.yml
   - 說明 tasks, handlers, vars 的作用

4. **實際部署** (10 分鐘)
   - 執行 deploy.sh
   - 觀察輸出訊息

5. **驗證與測試** (5 分鐘)
   - 訪問網站
   - 檢查 Nginx 狀態
   - 查看部署的檔案
