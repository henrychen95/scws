# 詞典與規則

SCWS 的切分與關鍵詞統計依賴詞典和規則。發行套件附有規則檔及小型測試詞典；正式詞典請自行準備，並確認其資料來源、使用條件與編碼。

## 選擇編碼

文字、詞典、規則與分詞實例的編碼必須一致。UTF-8 使用 API 的 `utf8` 或 CLI 的 `-c utf8`；GBK 使用 `gbk`。

| 資料編碼 | 內附規則檔 | PHP 自動載入的詞典名稱 |
| --- | --- | --- |
| GBK | `etc/rules.ini` | `dict.xdb` |
| UTF-8 | `etc/rules.utf8.ini` | `dict.utf8.xdb` |
| 繁體中文 UTF-8 | `etc/rules_cht.utf8.ini` | `dict.utf8.xdb` |

PHP 若要使用繁體中文規則檔，請透過 `set_rule()` 明確指定；自動載入只按編碼尋找 `rules.utf8.ini`。規則檔會隨核心安裝到 prefix 的 `etc/`。

## 文字詞典

每行一個詞，欄位以空格或 Tab 分隔：

```text
# 詞語 TF IDF 詞性
中文 10 5 n
分詞 10 5 n
測試 10 5 n
```

只有詞語欄位必填；建議明確提供所有欄位，方便控制詞頻、權重及詞性。以 `#` 開頭的行為註解。TF 為詞頻，IDF 用於詞語權重，詞性為最多兩個位元組的標記。

PHP 以 `SCWS_XDICT_TXT` 載入，C API 使用相同名稱的常數，CLI 依 `.txt` 副檔名辨識。載入前先設定編碼。

`tests/dict.utf8.txt` 只有三個測試詞，用來確認編碼、安裝與介面運作，不適合作為一般中文文本的正式詞庫。

## XDB 詞典

XDB 是 SCWS 使用的二進位詞典格式。可用已安裝的轉換器建立：

```sh
scws-gen-dict -c utf8 -i tests/dict.utf8.txt -o /tmp/scws-test.utf8.xdb
```

PHP／C API 使用 `SCWS_XDICT_XDB` 載入。需要載入記憶體時，可組合 `SCWS_XDICT_XDB | SCWS_XDICT_MEM`。

建立時的編碼必須與後續讀取時一致；不要僅重新命名 GBK 詞典來當成 UTF-8 詞典。

## 多詞典

`set_dict()` 取代先前載入的詞典；`add_dict()` 保留原詞典並加入新詞典，後加入的優先序較高。CLI 可用冒號分隔多個詞典路徑。

```sh
scws -c utf8 -d base.utf8.xdb:custom.utf8.txt \
  -r /usr/local/etc/rules.utf8.ini -i input.txt
```

## PHP 預設路徑

設定 `scws.default.fpath=/usr/local/etc` 後，UTF-8 預設尋找 `dict.utf8.xdb` 與 `rules.utf8.ini`。必須另外把正式詞典放入該目錄，或在程式中使用自己的路徑。

詳見 [PHP 設定](../phpext/README.md#設定)與 [安裝說明](../INSTALL.md)。

## 結果檢查

分詞前先檢查詞典和規則載入是否成功。若結果只剩零散單字，請先確認是否未載入正式詞典、路徑錯誤、使用了小型測試詞典，或編碼不一致。