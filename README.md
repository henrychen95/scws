# SCWS

SCWS（Simple Chinese Word Segmentation）是以 C 撰寫的中文分詞引擎，提供共享函式庫、命令列工具與 PHP 擴充，支援 UTF-8、GBK、詞典分詞及關鍵詞統計。

這是由 henrychen95 維護與發行的版本，主要維護 Linux 安裝流程與 PHP 8.4 相容性。核心版本為 **1.2.4**，PHP 擴充模組版本為 **0.2.4**。

- [下載發行套件](https://github.com/henrychen95/scws/releases)
- [回報問題](https://github.com/henrychen95/scws/issues)
- [原始碼](https://github.com/henrychen95/scws)

## 下載與安裝

正式發行附件為 `scws-1.2.4.tar.gz` 與 `scws-1.2.4.tar.gz.sha256`，包含預先產生的 `configure` 與建置檔案。在 Linux 安裝時仍需要 C 編譯器與 Make。

使用 Git checkout 或 GitHub 自動產生的 Source code 壓縮檔時，請依 [Git 原始碼建置步驟](INSTALL.md#從-git-原始碼建置)安裝。

取得正式發行附件後，在 Debian／Ubuntu 安裝：

```sh
sudo apt-get update
sudo apt-get install build-essential
sha256sum -c scws-1.2.4.tar.gz.sha256
tar -xzf scws-1.2.4.tar.gz
cd scws-1.2.4
./configure --prefix=/usr/local
make -j2
sudo make install
sudo ldconfig
/usr/local/bin/scws -v
```

PHP 8.4 擴充需另行編譯與啟用，請接著閱讀 [安裝說明](INSTALL.md)。

## 快速試用

在解壓後的套件根目錄，使用內附的小型測試詞典：

```sh
printf '中文分詞測試\n' | /usr/local/bin/scws \
  -c utf8 -d tests/dict.utf8.txt -r /usr/local/etc/rules.utf8.ini -N
```

結果會包含 `中文 分詞 測試`。測試詞典只有少量詞彙；正式使用請準備符合資料編碼與用途的詞典，詳見 [詞典與規則](docs/DICTIONARIES.md)。

## 文件

| 文件 | 內容 |
| --- | --- |
| [安裝](INSTALL.md) | Linux 核心、PHP 8.4 擴充、個人目錄安裝與問題排查 |
| [命令列工具](docs/CLI.md) | 分詞、關鍵詞統計與詞典轉換 |
| [PHP 使用與 API](phpext/README.md) | 物件式／函式式範例、設定與回傳資料 |
| [C API](API.md) | libscws 整合、記憶體管理與範例 |
| [詞典與規則](docs/DICTIONARIES.md) | 文字詞典、XDB、編碼與規則檔 |
| [發行流程](RELEASING.md) | 套件製作、驗證、版本標籤與草稿 Release |
| [版本紀錄](NEWS) | 本專案發行變更 |

## 驗證範圍

1.2.4 已在 Ubuntu 22.04.5 LTS、GCC 11.4、PHP 8.4.26 NTS 上通過：

- 核心的分離目錄建置、安裝、解除安裝與清理檢查（`make distcheck`）。
- 從發行壓縮檔重新建置並安裝函式庫、命令列工具與 PHP 擴充。
- 文字／XDB 詞典、UTF-8 分詞、物件式／函式式 API，以及 200 次物件生命週期檢查。

GitHub Actions 設定使用 Ubuntu 24.04 與 PHP 8.4；執行結果請以該版本的 Actions 紀錄為準。其他 Linux 發行版、PHP 版本與 Windows 尚未列入本版實測範圍。本專案目前提供 Linux 原始碼套件，未提供 Windows DLL。

## 開發目錄

`libscws/` 為核心、`cli/` 為命令列工具、`phpext/` 為 PHP 擴充，`etc/` 存放規則檔。`scripts/` 與 `tests/` 用於發行及離線安裝驗證。

`web/`、`dev/` 與 Windows 專案檔保留作歷史參考；目前的下載、問題回報與文件以此 repository 為準。本機若有 `src/scws-1.2.1`，那是原版參照資料，不參與本專案打包。

## 來源與授權

本專案衍生自 hightman 的 [上游 SCWS](https://github.com/hightman/scws)，保留原作者與貢獻者的著作權及授權聲明。核心授權條款見 [COPYING](COPYING)，作者資訊見 [AUTHORS](AUTHORS)；個別檔案的授權聲明亦予保留。
