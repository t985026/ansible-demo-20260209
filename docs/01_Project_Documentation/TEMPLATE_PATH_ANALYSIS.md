# 🔍 Jinja2 模板路徑影響分析報告

**分析日期**: 2026-02-09  
**分析者**: Product Manager Agent  
**問題**: Playbook 移至 `tasks/` 目錄後，Jinja2 模板引用是否受影響？

---

## ✅ 結論：**不受影響** 🎉

將 playbook 從根目錄移至 `tasks/` 子目錄**不會影響** Jinja2 模板的正常運作。

---

## 📊 當前狀態分析

### 1. 模板引用位置

#### 根目錄 Playbook (`tasks/web_server_setup.yml`)

```yaml
# 第 75-76 行
- name: 9. Deploy custom index.html from template
  template:
    src: templates/index.html.j2  # ← 路徑引用
    dest: "{{ web_root }}/index.html"
    
# 第 83-84 行
- name: 10. Deploy Nginx config from template
  template:
    src: templates/nginx.conf.j2  # ← 路徑引用
    dest: /etc/nginx/nginx.conf
```

#### Demo Playbook (`demo/tasks/web_server_setup.yml`)

```yaml
# 第 75-76 行
- name: 9. Deploy custom index.html from template
  template:
    src: templates/index.html.j2  # ← 路徑引用
    dest: "{{ web_root }}/index.html"
    
# 第 84-85 行
- name: 10. Deploy Nginx config from template
  template:
    src: templates/nginx.conf.j2  # ← 路徑引用
    dest: /etc/nginx/nginx.conf
```

---

## 🛠️ Ansible 模板查找機制

### Template 模組的路徑解析順序

Ansible 的 `template` 模組會按以下順序查找模板文件：

1. **相對於 playbook 執行目錄** (最優先)
   - 執行 `ansible-playbook` 命令時的當前工作目錄

2. **相對於 playbook 文件所在目錄**
   - 如果 playbook 在 `tasks/` 中，會從 playbook 所在位置查找

3. **Ansible 配置的 template 路徑**
   - 通常是 `ansible.cfg` 中定義的路徑

4. **Role 的 templates 目錄**
   - 如使用 roles 結構時

---

## 📁 目錄結構對照

### 執行根目錄 Playbook

```bash
# 執行命令（從專案根目錄）
ansible-playbook -i inventory/staging tasks/web_server_setup.yml

# 目錄結構
ansible-demo-20260209/           ← 執行目錄 (CWD)
├── tasks/
│   └── web_server_setup.yml    ← Playbook 位置
└── templates/                   ← 模板位置
    ├── index.html.j2
    └── nginx.conf.j2

# 路徑解析
src: templates/index.html.j2
→ 解析為: ansible-demo-20260209/templates/index.html.j2 ✅
```

### 執行 Demo Playbook

```bash
# 執行命令（從 demo/ 目錄）
cd demo
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml

# 目錄結構
demo/                             ← 執行目錄 (CWD)
├── tasks/
│   └── web_server_setup.yml    ← Playbook 位置
└── templates/                   ← 模板位置
    ├── index.html.j2
    └── nginx.conf.j2

# 路徑解析
src: templates/index.html.j2
→ 解析為: demo/templates/index.html.j2 ✅
```

---

## 🎯 關鍵原因

### 為什麼不受影響？

**因為使用的是相對路徑 `templates/`，而非 `../templates/`**

```yaml
# ✅ 正確：相對於執行目錄的路徑
src: templates/index.html.j2

# ❌ 錯誤範例：如果使用這種路徑就會有問題
src: ../templates/index.html.j2  # 這種寫法在移動後會失效
```

Ansible 的 `template` 模組預設從**執行 ansible-playbook 命令的目錄**（即專案根目錄）開始查找，而非從 playbook 文件所在的目錄。

---

## 🧪 驗證測試

### 測試 1: 根目錄 Playbook

```bash
# 從專案根目錄執行
cd /d/Project/ansible-demo-20260209
ansible-playbook -i inventory/staging tasks/web_server_setup.yml --check

# 預期結果
✅ templates/index.html.j2 找到
✅ templates/nginx.conf.j2 找到
```

### 測試 2: Demo Playbook

```bash
# 從 demo 目錄執行
cd /d/Project/ansible-demo-20260209/demo
ansible-playbook -i inventory/hosts tasks/web_server_setup.yml --check

# 預期結果
✅ templates/index.html.j2 找到 (demo/templates/)
✅ templates/nginx.conf.j2 找到 (demo/templates/)
```

---

## 📋 實際路徑映射

### 根目錄結構

```
ansible-demo-20260209/
├── tasks/                          ← Playbook 新位置
│   ├── base_system_setup.yml
│   ├── complete_bootstrap.yml
│   ├── preflight_check.yml
│   ├── system_hardening.yml
│   └── web_server_setup.yml       ← 引用 templates/
│
└── templates/                      ← 模板文件位置
    ├── index.html.j2              ✅ 可正常找到
    └── nginx.conf.j2              ✅ 可正常找到
```

### Demo 目錄結構

```
demo/
├── tasks/                          ← Playbook 新位置
│   └── web_server_setup.yml       ← 引用 templates/
│
└── templates/                      ← 模板文件位置
    ├── index.html.j2              ✅ 可正常找到
    └── nginx.conf.j2              ✅ 可正常找到
```

---

## ⚠️ 需要注意的情況

### 情況 1: 如果使用相對父目錄路徑

```yaml
# ❌ 這種寫法移動後會失效
template:
  src: ../templates/index.html.j2  # 移動前可能有效，移動後會失效
```

### 情況 2: 如果從非專案根目錄執行

```bash
# ❌ 錯誤：從 tasks/ 目錄執行
cd tasks/
ansible-playbook -i ../inventory/staging web_server_setup.yml
# templates/ 會找不到，因為 CWD 是 tasks/

# ✅ 正確：從專案根目錄執行
cd /d/Project/ansible-demo-20260209
ansible-playbook -i inventory/staging tasks/web_server_setup.yml
```

---

## 💡 最佳實踐建議

### 1. **保持相對路徑風格** ✅

```yaml
# 推薦：相對於專案根目錄
template:
  src: templates/index.html.j2
```

### 2. **統一執行位置** ✅

```bash
# 始終從專案根目錄執行 playbook
cd /d/Project/ansible-demo-20260209
ansible-playbook -i inventory/staging tasks/XXX.yml
```

### 3. **使用絕對路徑（進階）**

```yaml
# 如需完全避免路徑問題，可使用 playbook_dir 變數
template:
  src: "{{ playbook_dir }}/../templates/index.html.j2"
# 但通常不需要，維持簡單的相對路徑即可
```

### 4. **Role 結構（推薦給大型專案）**

```
# 使用 Ansible Role 結構可完全避免路徑問題
roles/
  webserver/
    templates/
      index.html.j2
    tasks/
      main.yml  # 引用時直接用 index.html.j2
```

---

## 📊 測試清單

執行以下測試確認模板路徑正常：

- [ ] **Syntax Check**

  ```bash
  ansible-playbook tasks/web_server_setup.yml --syntax-check
  ```

- [ ] **Dry Run (根目錄)**

  ```bash
  ansible-playbook -i inventory/staging tasks/web_server_setup.yml --check
  ```

- [ ] **Dry Run (Demo)**

  ```bash
  cd demo && ansible-playbook -i inventory/hosts tasks/web_server_setup.yml --check
  ```

- [ ] **實際執行測試**

  ```bash
  # 在測試環境中實際部署，觀察 template 任務是否成功
  ansible-playbook -i inventory/staging tasks/web_server_setup.yml -v
  ```

---

## 🎓 技術解釋

### Ansible Template 模組的文件查找邏輯

```python
# Ansible 內部邏輯（簡化版）
def find_template(template_path, playbook_dir, cwd):
    search_paths = [
        cwd,                          # 1. 當前工作目錄
        playbook_dir,                 # 2. Playbook 所在目錄
        os.path.join(cwd, 'templates'),  # 3. CWD/templates
        # ... 其他路徑
    ]
    
    for path in search_paths:
        full_path = os.path.join(path, template_path)
        if os.path.exists(full_path):
            return full_path
    
    raise TemplateNotFound(template_path)
```

### 您的情況

```
template_path = "templates/index.html.j2"
cwd = "/d/Project/ansible-demo-20260209"  # 專案根目錄
playbook_dir = "/d/Project/ansible-demo-20260209/tasks"

# 查找順序：
1. /d/Project/ansible-demo-20260209/templates/index.html.j2  ← 找到！✅
```

---

## ✅ 最終結論

**無需任何修改**！您的 playbook 移動到 `tasks/` 目錄後，Jinja2 模板引用完全正常，原因是：

1. ✅ 使用的是正確的相對路徑風格 (`templates/`)
2. ✅ Ansible 從執行目錄（專案根目錄）查找模板
3. ✅ 目錄結構保持 `templates/` 在專案根目錄或 demo/ 目錄

---

## 📞 如果遇到問題

如果將來遇到模板找不到的錯誤，請檢查：

1. **執行位置** - 確保從專案根目錄執行
2. **路徑寫法** - 確認使用 `templates/` 而非 `../templates/`
3. **文件存在** - 確認模板文件確實存在
4. **權限問題** - 確認對模板文件有讀取權限

---

**分析完成時間**: 2026-02-09 15:35  
**狀態**: ✅ 無需修改，模板引用正常  
**建議**: 可執行 dry run 測試確認
