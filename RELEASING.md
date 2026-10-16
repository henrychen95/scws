# 發行與驗證

本專案以 GitHub Release 附件提供可在 Linux 編譯安裝的 SCWS 原始碼套件。發行包包含產生好的 `configure`、`Makefile.in` 與建置輔助檔案。

## 版本與內容

核心／套件版本由 `configure.ac` 的 `AC_INIT` 決定；目前為 1.2.4。PHP 擴充模組版本獨立定義於 `phpext/php_scws.c`，目前為 0.2.4。

正式附件：

```text
scws-1.2.4.tar.gz
scws-1.2.4.tar.gz.sha256
```

套件收錄核心、CLI、PHP 擴充、規則檔、文件及離線測試資料。正式詞典需另行取得。`src/`、歷史網站與開發資料不屬於安裝套件。

## 本機製作

使用乾淨的原始碼工作目錄，安裝 C 編譯器、Make、Autoconf、Automake、Libtool，以及同一套 PHP 8.4 的 CLI、開發標頭檔、phpize 和 php-config。

在 repository 根目錄執行：

```sh
sh scripts/make-release.sh
sh scripts/check-release.sh dist/scws-1.2.4.tar.gz
```

第一步會產生建置檔案並執行 `make distcheck`，通過後將套件與 SHA256 放入 `dist/`。

第二步使用暫存目錄，從真正的發行壓縮檔驗證：

- 禁用核心的 Autotools 再生後，完成分離目錄建置與安裝。
- 執行已安裝的 CLI 與詞典轉換器。
- 編譯並將 PHP 擴充安裝至暫存目錄，再載入測試。
- 執行離線詞典分詞與字串／物件生命週期回歸檢查。

測試結束會清除暫存安裝目錄，不修改主機 PHP 設定。若需選擇特定 PHP 工具：

```sh
PHP=php8.4 PHPIZE=phpize8.4 PHP_CONFIG=php-config8.4 \
  sh scripts/check-release.sh dist/scws-1.2.4.tar.gz
```

## GitHub Actions

流程定義於原始碼中的 `.github/workflows/release.yml`，執行環境為 Ubuntu 24.04 與 PHP 8.4。

| 觸發方式 | 結果 |
| --- | --- |
| Pull request | 打包與安裝驗證，通過後上傳 artifact |
| 手動執行 | 打包與安裝驗證，通過後上傳 artifact |
| 推送 `v*` tag | 檢查 tag 與套件版本一致，驗證通過後建立附有套件的 Draft Release |

每次發行：

1. 更新核心版本與本版相關文件、`NEWS`；若修改擴充版本，同步檢查其版本資訊。
2. 在待發行原始碼上完成本機驗證，提交變更，讓 commit、PR 與 ClickUp Task 相互關聯。
3. 對確定要發行的 commit 建立版本 tag，例如套件 1.2.4 對應 `v1.2.4`，再推送該 tag。
4. 確認 Actions 成功，檢查 Draft Release 的附件、SHA256、變更說明及來源 commit。
5. 由維護者發佈草稿，確認 [Releases](https://github.com/henrychen95/scws/releases)可以下載附件。

推送 tag 本身會觸發草稿建立；流程不會自動公開發佈草稿。發行後請讓附件與來源 tag 保持一致；若內容需要變更，使用新的版本。

## 發行紀錄

記錄作業系統、編譯器、PHP 版本、測試結果、來源 commit 與最終套件 SHA256。若尚未在某個環境實測，請在說明中區分測試結果與預期支援範圍。

`make distcheck` 驗證核心建置與安裝；PHP 安裝／分詞檢查由 `check-release.sh` 負責。舊 `phpext/scws_test.php` 需要額外的正式詞典，不包含在離線測試結果中。

## 文件與授權

套件必須保留 `COPYING`、`AUTHORS` 與原始檔案內的授權／著作權聲明。README 的來源說明保留上游連結。下載、問題回報與安裝說明均指向本專案。
