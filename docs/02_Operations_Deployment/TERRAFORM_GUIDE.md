# Terraform DevOps 工作站指南

本指南說明如何使用 **`tasks/terraform_setup.yml`** Playbook 快速建置一個功能完整的 Terraform 開發環境，以及如何使用預裝的 DevOps 工具。

## 🎯 功能總覽

這個 Playbook 會在目標主機 (預設為 `webservers` 群組) 上安裝以下核心工具：

1. **Terraform**: HashiCorp 的基礎設施即代碼 (IaC) 工具。
2. **TFLint**: Terraform 代碼靜態分析工具，用於檢查錯誤和最佳實踐。
3. **tfenv**: Terraform 版本管理器，允許在不同專案間切換版本。
4. **terraform-docs**: 自動生成 Terraform 模組文件的工具。

此外，它還會：

- 設定環境變數與 Alias (`tf` = `terraform`)
- 建立標準工作區目錄 (`~/terraform_workspace`)
- 部署範例代碼以供測試

---

## 🚀 部署方式

請在專案的 `tasks/` 目錄下執行以下指令：

```bash
# 切換到 tasks 目錄
cd tasks

# 執行 Playbook (假設 inventory 在 ../inventory/staging)
ansible-playbook -i ../inventory/staging terraform_setup.yml
```

---

## 🛠️ 工具使用說明

### 1. Terraform (IaC 核心)

基礎設施的主要操控工具。

```bash
# 檢查版本
terraform version

# 使用 Alias (Playbook 已自動設定)
tf plan
tf apply
```

### 2. TFLint (代碼檢查)

在執行 `terraform plan` 之前，先檢查代碼是否有潛在錯誤。

```bash
# 初始化 TFLint (下載 plugin)
tflint --init

# 執行檢查
tflint
```

### 3. tfenv (版本管理)

如果不同專案需要不同版本的 Terraform，使用 `tfenv` 管理。

```bash
# 列出可安裝版本
tfenv list-remote

# 安裝特定版本
tfenv install 1.5.0

# 切換使用版本
tfenv use 1.5.0
```

### 4. terraform-docs (文件生成)

自動為 Terraform 模組生成 Markdown 文件。

```bash
# 生成文件並輸出到標準輸出
terraform-docs markdown table .

# 生成文件並寫入 README.md
terraform-docs markdown table . --output-file README.md
```

---

## ✅ 驗證部署

Playbook 執行完畢後，您可以登入目標主機進行驗證：

1. **檢查工作區**:

    ```bash
    cd ~/terraform_workspace/lab01
    ls -l
    # 應看到 main.tf
    ```

2. **執行測試**:

    ```bash
    cd ~/terraform_workspace/lab01
    terraform init
    terraform apply -auto-approve
    ```

    **預期輸出**:

    ```
    null_resource.example: Creating...
    null_resource.example: Provisioning with 'local-exec'...
    null_resource.example (local-exec): Executing: ["/bin/sh" "-c" "echo 'Hello Ansible Terraform!'"]
    null_resource.example (local-exec): Hello Ansible Terraform!
    null_resource.example: Creation complete after 0s [id=...]
    
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```

---

## 📂 檔案結構

部署後的環境結構如下：

```
/home/webadmin/           # 使用者家目錄
├── .tfenv/               # tfenv 安裝目錄
├── .local/bin/           # 使用者執行檔目錄
├── terraform_workspace/  # Terraform 專案工作區
│   └── lab01/            # 範例專案
│       └── main.tf       # 測試代碼
└── .bashrc               # 環境變數與 Alias 設定
```

---

## 🔍 常見問題

**Q: 執行 `tf` 指令找不到？**
A: 請嘗試重新登入 SSH，或執行 `source ~/.bashrc` 讓設定生效。

**Q: 如何更新工具版本？**
A: 修改 `tasks/terraform_setup.yml` 中的 `tflint_version` 或 `tf_docs_version` 變數，然後重新執行 Playbook。
