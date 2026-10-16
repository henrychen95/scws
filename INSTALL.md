# Linux 與 PHP 8.4 安裝

本文件適用於 henrychen95/scws 的 1.2.4 原始碼發行套件。安裝完成後可使用 `libscws`、`scws`、`scws-gen-dict`，PHP 擴充需另行編譯。

## 取得套件

到 [Releases](https://github.com/henrychen95/scws/releases)下載附件：

- `scws-1.2.4.tar.gz`
- `scws-1.2.4.tar.gz.sha256`

若尚未發佈該版本，請使用下方的 Git 原始碼建置流程。正式附件包含 `configure`；GitHub 自動產生的 Source code 壓縮檔需先產生建置檔案。

將兩個附件放在同一目錄：

```sh
sha256sum -c scws-1.2.4.tar.gz.sha256
tar -xzf scws-1.2.4.tar.gz
cd scws-1.2.4
```

校驗結果應顯示 `scws-1.2.4.tar.gz: OK`。

## 安裝核心

Debian／Ubuntu：

```sh
sudo apt-get update
sudo apt-get install build-essential
./configure --prefix=/usr/local
make -j2
sudo make install
sudo ldconfig
/usr/local/bin/scws -v
```

安裝位置：

| 內容 | 預設位置 |
| --- | --- |
| 命令列工具 | `/usr/local/bin/scws`、`/usr/local/bin/scws-gen-dict` |
| 共享函式庫 | `/usr/local/lib/` |
| C 標頭檔 | `/usr/local/include/scws/` |
| 規則檔 | `/usr/local/etc/rules*.ini` |

正式套件的核心建置不需要安裝 Autoconf、Automake 或 Libtool 開發工具。其他 Linux 發行版請先安裝對應的 C 編譯器、Make 與開發標頭檔。

### 安裝到個人目錄

可用以下指令取代上方的配置、安裝步驟：

```sh
./configure --prefix="$HOME/.local"
make -j2
make install
"$HOME/.local/bin/scws" -v
```

後續 PHP 的 `--with-scws` 應改用相同目錄。若執行環境找不到共享函式庫，可在該執行環境設定 `LD_LIBRARY_PATH="$HOME/.local/lib"`，或依主機的函式庫管理方式設定搜尋路徑。

## 安裝 PHP 8.4 擴充

先從目前 PHP 的安裝來源取得相符的 PHP 8.4 開發套件。以下使用 `php8.4`、`phpize8.4`、`php-config8.4`；若環境採無版本後綴的名稱，請改用同一套 PHP 的 `php`、`phpize`、`php-config`。

```sh
php8.4 -v
php-config8.4 --version
sudo apt-get install autoconf
cd phpext
phpize8.4
./configure --with-scws=/usr/local --with-php-config="$(command -v php-config8.4)"
make -j2
sudo make install
```

`phpize` 仍需要 Autoconf。請確認開發套件與實際執行的 PHP 版本、架構和執行緒模式一致。

查看設定檔位置：

```sh
php8.4 --ini
```

在目標 PHP 的設定檔加入一次：

```ini
extension=scws.so
scws.default.charset=utf8
scws.default.fpath=/usr/local/etc
```

確認載入：

```sh
php8.4 --ri scws
```

PHP-FPM／Apache 可能使用另一份設定檔；請在對應環境啟用，並重新啟動使用該擴充的服務。核心若安裝到其他 prefix，請同步修改 `--with-scws` 與 `scws.default.fpath`。

接著依 [PHP 範例](phpext/README.md)測試分詞。

## 準備詞典

發行套件包含規則檔及安裝測試用詞典。正式詞典需自行準備。

設定 `scws.default.charset=utf8` 與 `scws.default.fpath=/usr/local/etc` 時，預設會嘗試載入：

```text
/usr/local/etc/dict.utf8.xdb
/usr/local/etc/rules.utf8.ini
```

也可在程式中指定自己的詞典及規則檔。文字、詞典與規則檔的編碼必須一致，詳見 [詞典與規則](docs/DICTIONARIES.md)。

## 從 Git 原始碼建置

Git checkout 與 GitHub Source code 壓縮檔需要先產生建置檔案。取得原始碼後，在 repository 根目錄執行：

```sh
sudo apt-get install build-essential autoconf automake libtool
sh acprep
./configure --prefix=/usr/local
make -j2
sudo make install
sudo ldconfig
```

再依前述步驟編譯 PHP 擴充。請勿進入本機的 `src/scws-1.2.1` 參照目錄建置本版。

## 常見問題

| 現象 | 處理方式 |
| --- | --- |
| 找不到 `./configure` | 確認下載的是發行附件，或在 Git 原始碼根目錄執行 `sh acprep`。 |
| 找不到 `phpize8.4`／`php-config8.4` | 安裝目前 PHP 來源提供的相符開發套件，確認工具名稱與 PATH。 |
| PHP 載入時找不到 `libscws.so` | 確認核心已安裝並執行 `sudo ldconfig`；自訂 prefix 需設定函式庫搜尋路徑。 |
| CLI 可用，網頁端找不到擴充 | 檢查 PHP-FPM／Apache 的 PHP 版本及設定檔，啟用後重新啟動服務。 |
| 擴充已載入，但分詞結果不符預期 | 檢查詞典是否載入、編碼是否一致，以及是否誤用測試詞典。 |

仍有問題時，請在 [Issues](https://github.com/henrychen95/scws/issues)附上作業系統、PHP／核心版本、安裝指令與完整錯誤訊息。製作套件的方式見 [發行流程](RELEASING.md)。