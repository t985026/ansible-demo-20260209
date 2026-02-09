# 🔄 Demo 更新日誌

## 版本 1.1 - 2026-02-09

### 🔧 移除防火牆配置

**原因**: Killercoda 環境預設防火牆服務關閉

**變更內容**:

#### 1. web_server_setup.yml

- ❌ 移除: UFW 防火牆啟用任務（第 106-108 行）
- ✅ 更新: 任務編號從 19/20 調整為 13/14
- ✅ 簡化: 階段從七個減少到六個

**修改前**:

```yaml
# --- 階段七：網路安全性 ---
- name: 16. Enable UFW (啟用 UFW 防火牆)
  ufw:
    state: enabled
```

**修改後**:

```yaml
# (已移除此段落)
```

#### 2. Readme.md

- ❌ 移除: "防火牆已配置" 驗證項目
- ✅ 保留: Nginx、網站目錄、自訂首頁驗證項

#### 3. CHECKLIST.md

- ❌ 移除: "錯誤 4: UFW 防火牆阻擋" 排查說明
- ✅ 保留: SSH、Ansible、權限相關的故障排除

### 📊 影響範圍

- **總任務數**: 從 20 個減少到 14 個
- **執行時間**: 預計減少 10-15 秒
- **相容性**: ✅ 完全相容 Killercoda 環境
- **安全性**: ℹ️ Killercoda 為學習環境，無需防火牆配置

### ✅ 驗證清單

現在部署完成後應看到：

1. ✅ Nginx 已安裝並執行
2. ✅ 網站目錄已創建 (`/var/www/demo`)
3. ✅ 自訂首頁已部署
4. ~~✅ 防火牆已配置~~ (已移除)

### 🎯 後續建議

如果在生產環境使用，建議添加：

```yaml
# 僅生產環境需要
- name: Configure firewall
  ufw:
    rule: allow
    port: '80'
    proto: tcp
  when: ansible_env.ENVIRONMENT == "production"
```

---

## 版本 1.0 - 2026-02-09

### 初始發布

**主要功能**:

- ✅ Nginx 自動安裝與配置
- ✅ 網站目錄創建與權限設定
- ✅ Jinja2 模板部署
- ✅ 使用者管理
- ✅ 日誌目錄配置
- ✅ Handlers 自動重啟服務

**支援環境**:

- Killercoda Ubuntu Playground
- 本地虛擬機環境
- 測試與培訓場景

---

**維護者**: Ansible Demo Project Team  
**最後更新**: 2026-02-09 13:53
