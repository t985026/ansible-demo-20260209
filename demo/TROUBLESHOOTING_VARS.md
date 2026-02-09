# 🔧 Killercoda 執行錯誤修復指南

**錯誤**: `'web_root' is undefined`  
**原因**: Ansible 找不到 group_vars 下的變數文件

---

## 🎯 問題診斷

### 錯誤訊息

```
fatal: [node01]: FAILED! => {
    "msg": "The task includes an option with an undefined variable. 
    The error was: 'web_root' is undefined"
}
```

### 可能原因

1. **執行目錄錯誤** - 不在 `demo/` 目錄中執行
2. **group_vars 路徑問題** - Ansible 找不到變數文件
3. **inventory 配置問題** - 主機群組定義不符

---

## ✅ 解決方案

### 方案 1：確認執行目錄（推薦）

```bash
# 確保在 demo/ 目錄中執行
cd /root/ansible-demo-20260209/demo

# 確認當前目錄
pwd
# 應輸出：/root/ansible-demo-20260209/demo

# 確認 group_vars 存在
ls -la group_vars/
# 應看到：all.yml 和 webservers.yml

# 重新執行
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml
```

---

### 方案 2：使用部署腳本

```bash
cd /root/ansible-demo-20260209/demo
chmod +x deploy.sh
./deploy.sh
```

---

### 方案 3：顯式指定 group_vars 路徑

如果上述方法無效，在 playbook 中臨時添加變數：

編輯 `tasks/web_server_setup.yml`，在 `vars_files:` 後面添加：

```yaml
---
- name: Web Server Deployment and Configuration
  hosts: webservers
  become: yes

  # 臨時解決方案：顯式載入變數
  vars:
    web_root: /var/www/demo
    log_dir: /var/log/nginx_custom
    web_user: webadmin

  vars_files:
    - secrets/credentials.yml
```

**注意**：這只是臨時方案，正確做法應該是使用 group_vars。

---

## 🔍 診斷命令

### 1. 檢查當前目錄

```bash
pwd
```

### 2. 檢查 group_vars 文件存在

```bash
ls -la group_vars/
cat group_vars/webservers.yml
```

### 3. 測試變數載入

```bash
ansible -i inventory/hosts webservers -m debug -a "var=web_root"
```

預期輸出應該是：

```json
{
    "web_root": "/var/www/demo"
}
```

如果輸出是 `undefined`，則表示 Ansible 未載入 group_vars。

---

## 📋 完整檢查清單

執行以下步驟診斷問題：

```bash
# 1. 進入正確目錄
cd /root/ansible-demo-20260209/demo

# 2. 列出文件結構
ls -la
# 應該看到：group_vars/, inventory/, tasks/, templates/, deploy.sh

# 3. 確認 group_vars 內容
cat group_vars/webservers.yml
# 應該包含：web_root, log_dir, web_user

# 4. 確認 inventory 配置
cat inventory/hosts
# 應該包含：[webservers]
#           node01

# 5. 測試變數
ansible -i inventory/hosts webservers -m debug -a "var=hostvars[inventory_hostname]"

# 6. 重新執行 playbook
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml -v
```

---

## 🎯 Killercoda 正確執行流程

### 完整步驟（從頭開始）

```bash
# 1. 克隆或進入專案
cd /root
git clone https://github.com/t985026/ansible-demo-20260209.git
cd ansible-demo-20260209/demo

# 2. 確認目錄結構
ls -la
# 確保看到：
# - group_vars/
# - inventory/
# - tasks/
# - templates/
# - deploy.sh

# 3. 確認變數文件
cat group_vars/webservers.yml

# 4. 執行部署（使用腳本）
chmod +x deploy.sh
./deploy.sh

# 或手動執行
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml
```

---

## ⚠️ 常見錯誤

### 錯誤 1：從錯誤的目錄執行

```bash
# ❌ 錯誤
cd /root/ansible-demo-20260209
ansible-playbook -i demo/inventory/hosts demo/tasks/web_server_setup.yml
# group_vars 找不到，因為 Ansible 從當前目錄找

# ✅ 正確
cd /root/ansible-demo-20260209/demo
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml
```

### 錯誤 2：相對路徑問題

```bash
# ✅ 確保從 demo/ 目錄執行所有命令
cd /root/ansible-demo-20260209/demo
# 然後執行任何 ansible 命令
```

---

## 🔧 快速修復腳本

創建一個診斷腳本：

```bash
#!/bin/bash
# 保存為 debug_vars.sh

echo "=== Ansible 變數診斷 ==="
echo ""

echo "當前目錄:"
pwd
echo ""

echo "group_vars 文件:"
ls -la group_vars/ 2>/dev/null || echo "❌ group_vars 目錄不存在"
echo ""

echo "webservers.yml 內容:"
cat group_vars/webservers.yml 2>/dev/null || echo "❌ webservers.yml 不存在"
echo ""

echo "測試變數載入:"
ansible -i inventory/hosts webservers -m debug -a "var=web_root" 2>&1
echo ""

echo "=== 診斷完成 ==="
```

執行：

```bash
chmod +x debug_vars.sh
./debug_vars.sh
```

---

## 📖 Ansible group_vars 查找邏輯

Ansible 查找 `group_vars` 的順序：

1. **當前工作目錄 (CWD)**

   ```
   /root/ansible-demo-20260209/demo/group_vars/webservers.yml
   ```

2. **Playbook 所在目錄的父目錄**

   ```
   /root/ansible-demo-20260209/demo/group_vars/webservers.yml
   ```

3. **Inventory 所在目錄**

   ```
   /root/ansible-demo-20260209/demo/group_vars/webservers.yml
   ```

**關鍵**：確保從 `demo/` 目錄執行，這樣所有相對路徑都正確。

---

## ✅ 驗證修復

執行以下命令確認問題已解決：

```bash
cd /root/ansible-demo-20260209/demo

# 1. 變數測試
ansible -i inventory/hosts webservers -m debug -a "var=web_root"
# 預期：{"web_root": "/var/www/demo"}

# 2. Dry run
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml --check

# 3. 實際執行
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml

# 4. 驗證結果
curl http://node01
```

---

**修復時間**: 2026-02-09  
**狀態**: 提供完整診斷與解決方案  
**建議**: 始終從 demo/ 目錄執行所有命令
