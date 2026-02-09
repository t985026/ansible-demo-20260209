# Ansible 專案文件目錄

## 📂 資料夾結構說明

本資料夾已重新組織，將文件按類型分類以便於管理和查找。

### 01_Project_Documentation (專案文件)

專案核心文件，包含需求、架構設計和規劃。

- **01_PRD.md** - 產品需求規格書
- **02_Technical_Architecture.md** - 技術架構文件
- **04_Roadmap.md** - 專案路線圖
- **PROJECT_OVERVIEW.md** - 專案總覽

### 02_Operations_Deployment (操作與部署)

操作手冊、安裝指南和部署相關文件。

- **03_Operation_Manual.md** - 操作手冊
- **DEPLOYMENT_SUMMARY.md** - 部署摘要
- **INSTALLATION_GUIDE.md** - 安裝指南

### 03_Training_Materials (教學資料)

訓練教材、教學文件和簡報。

- **Ansible_Advanced_Tutorial.md** - Ansible 進階教學
- **Training_Manual.md** - 訓練手冊
- **Training_PPT.md** - 訓練簡報內容
- **Ansible_Advanced_Presentation.pptx** - 簡報檔案

### 04_Tools_Scripts (工具與腳本)

用於生成簡報、文件轉換等的工具和腳本。

- **generate_ppt.js** - 簡報生成腳本
- **html2pptx.js** - HTML 轉 PPTX 工具
- **package.json** - Node.js 專案設定檔
- **package-lock.json** - 依賴鎖定檔

### 05_Resources (資源檔案)

圖片、模板和其他資源文件。

- **image/** - 圖片資源資料夾
  - `03_Operation_Manual/` - 操作手冊相關圖片
- **ppt_source/** - PPT 來源 HTML 檔案
  - `slide1.html` ~ `slide8.html`

## 🔍 快速查找指南

### 想了解專案概況？

→ 查看 `01_Project_Documentation/PROJECT_OVERVIEW.md`

### 需要部署或安裝？

→ 查看 `02_Operations_Deployment/INSTALLATION_GUIDE.md`

### 學習 Ansible 進階技巧？

→ 查看 `03_Training_Materials/Ansible_Advanced_Tutorial.md`

### 需要生成簡報？

→ 查看 `04_Tools_Scripts/` 中的工具

## 📝 文件版本管理

- 所有 Markdown 文件使用 Git 進行版本控制
- `.gitignore` 已配置忽略臨時檔案和編譯產物
- 建議在修改文件前先查看最新版本

## 🛠️ 工具使用

如需使用簡報生成工具，請進入 `04_Tools_Scripts/` 資料夾：

```bash
cd 04_Tools_Scripts
npm install
node generate_ppt.js
```

## 📌 注意事項

1. **PPT 檔案被鎖定**：如果 `Ansible_Advanced_Presentation.pptx` 檔案被鎖定無法移動，請關閉 PowerPoint 後再執行移動操作
2. **路徑更新**：部分腳本可能需要更新檔案路徑以適應新的資料夾結構
3. **相對路徑**：文件中的圖片連結可能需要調整相對路徑

---

最後更新日期：2026年2月4日
