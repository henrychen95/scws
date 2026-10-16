# SCWS PHP 擴充

本擴充將 SCWS 核心提供為 PHP 物件與函式。現行發行目標為 PHP 8.4；1.2.4 的安裝與分詞已於 PHP 8.4.26 NTS 驗證。

核心及擴充的編譯、啟用方式見 [安裝說明](../INSTALL.md)。版本變更見 [NEWS](../NEWS)，問題請提交至 [本專案 Issues](https://github.com/henrychen95/scws/issues)。

## 物件式分詞

使用 `scws_new()` 建立帶有有效資源的 `SimpleCWS` 物件。直接 `new SimpleCWS()` 不會初始化分詞資源；不要自行改寫 `handle` 屬性。

以下範例從命令列接收 UTF-8 文字詞典與規則檔路徑，存成 `segment.php`：

```php
<?php
$scws = scws_new();
if ($scws === false) {
    throw new RuntimeException('無法建立 SCWS');
}
try {
    $scws->set_charset('utf8');
    if (!$scws->set_dict($argv[1], SCWS_XDICT_TXT)) {
        throw new RuntimeException('無法載入詞典');
    }
    if (!$scws->set_rule($argv[2])) {
        throw new RuntimeException('無法載入規則');
    }
    $scws->send_text('中文分詞測試');
    while ($rows = $scws->get_result()) {
        foreach ($rows as $row) {
            echo $row['word'], PHP_EOL;
        }
    }
} finally {
    $scws->close();
}
```

在解壓後的套件根目錄執行：

```sh
php8.4 segment.php tests/dict.utf8.txt /usr/local/etc/rules.utf8.ini
```

會依序輸出 `中文`、`分詞`、`測試`。正式 XDB 詞典請改用 `SCWS_XDICT_XDB`，詳見 [詞典與規則](../docs/DICTIONARIES.md)。

## 函式式分詞

將上述物件式操作換成對應的 `scws_*` 函式，第一個參數為 `scws_open()` 回傳的資源：

```php
<?php
$handle = scws_open();
if ($handle === false) {
    throw new RuntimeException('無法建立 SCWS');
}
try {
    scws_set_charset($handle, 'utf8');
    if (!scws_set_dict($handle, $argv[1], SCWS_XDICT_TXT)) {
        throw new RuntimeException('無法載入詞典');
    }
    if (!scws_set_rule($handle, $argv[2])) {
        throw new RuntimeException('無法載入規則');
    }
    scws_send_text($handle, '中文分詞測試');
    while ($rows = scws_get_result($handle)) {
        foreach ($rows as $row) {
            echo $row['word'], PHP_EOL;
        }
    }
} finally {
    scws_close($handle);
}
```

儲存後使用相同的命令列參數執行。關閉資源後不要再操作該資源。

## 設定

| php.ini 項目 | 擴充內建預設 | 用途 |
| --- | --- | --- |
| `scws.default.charset` | `gbk` | 新分詞資源的預設編碼；使用 UTF-8 時設為 `utf8` |
| `scws.default.fpath` | 未設定 | 自動載入詞典與規則檔的目錄 |

兩項都可在執行期設定。使用 UTF-8 並指定目錄時，會在未載入對應資源的情況下，嘗試尋找 `dict.utf8.xdb` 與 `rules.utf8.ini`；GBK 對應 `dict.xdb` 與 `rules.ini`。正式環境可直接透過 API 指定路徑，並檢查載入結果。

## API 對照

下表描述有效且尚未關閉的資源。函式式 API 除 `scws_open()`、`scws_new()` 與 `scws_version()` 外，第一個參數均為資源 handle。

| 物件方法 | 函式 | 行為／回傳值 |
| --- | --- | --- |
| 由 `scws_new()` 建立 | `scws_new()` | 回傳 `SimpleCWS`，建立失敗為 `false` |
| — | `scws_open()` | 回傳資源，建立失敗為 `false` |
| `close()` | `scws_close()` | 關閉資源；沒有回傳值 |
| `set_charset($charset)` | `scws_set_charset()` | 設定 `utf8` 或 `gbk`，回傳 `true` |
| `set_dict($path, $mode)` | `scws_set_dict()` | 取代詞典，成功為 `true`、失敗為 `false` |
| `add_dict($path, $mode)` | `scws_add_dict()` | 加入較高優先序詞典，成功為 `true`、失敗為 `false` |
| `set_rule($path)` | `scws_set_rule()` | 取代規則檔，成功為 `true`、失敗為 `false` |
| `set_ignore($yes)` | `scws_set_ignore()` | 設定是否略過標點，回傳 `true` |
| `set_multi($mode)` | `scws_set_multi()` | 設定複合分詞模式，範圍 0–15 |
| `set_duality($yes)` | `scws_set_duality()` | 設定零散單字二字聚合，回傳 `true` |
| `send_text($text)` | `scws_send_text()` | 指定本次文字，回傳 `true` |
| `get_result()` | `scws_get_result()` | 回傳一批結果陣列，讀取完畢為 `false` |
| `get_tops($limit = 10[, $attr])` | `scws_get_tops()` | 回傳依權重排序的關鍵詞陣列；省略 attr 表示不篩選 |
| `has_word($attr)` | `scws_has_word()` | 是否包含符合詞性條件的詞，回傳布林值 |
| `get_words($attr)` | `scws_get_words()` | 回傳符合詞性條件的詞語統計陣列 |
| `version()` | `scws_version()` | 回傳擴充與核心版本資訊字串 |

`get_result()` 需持續呼叫至 `false`，單次呼叫不保證讀取整段文字。再次呼叫 `send_text()` 會取代先前輸入；請先完成目前的結果讀取。

### 回傳欄位

`get_result()` 的每筆資料包含：

| 欄位 | 說明 |
| --- | --- |
| `word` | 詞語字串 |
| `off` | 詞語在輸入文字中的位元組偏移 |
| `len` | 詞語的位元組長度 |
| `idf` | 詞典／規則提供的 IDF |
| `attr` | 詞性標記 |

`get_tops()` 與 `get_words()` 的每筆資料包含 `word`、`times`、`weight`、`attr`。沒有符合項目時為空陣列。

### 常數與篩選

詞典模式為 `SCWS_XDICT_XDB`、`SCWS_XDICT_TXT`，可用位元 OR（`|`）搭配 `SCWS_XDICT_MEM` 載入記憶體。

複合分詞模式為 `SCWS_MULTI_NONE`、`SCWS_MULTI_SHORT`、`SCWS_MULTI_DUALITY`、`SCWS_MULTI_ZMAIN`、`SCWS_MULTI_ZALL`，可用 `|` 組合。PHP 的模式值為 0–15，請使用 PHP 擴充提供的常數。

詞性條件如 `n,v` 表示只取這些詞性，`~n,v` 表示排除它們；實際詞性取決於詞典與規則資料。

## 關鍵詞

在載入詞典與規則後，以同一個物件執行：

```php
$scws->send_text('中文分詞測試，中文分詞');
$tops = $scws->get_tops(5);
$words = $scws->get_words('n');
$hasNoun = $scws->has_word('n');
```

## 版本相容性

本版修正 PHP 8.2 動態屬性警告、PHP 8.4 物件資源取得，以及 PHP 7+ 輸入字串的保存與釋放。實測環境與發行驗證方式見 [README](../README.md)及 [發行流程](../RELEASING.md)。原始碼仍保留舊 PHP 相容分支，這不代表所有舊版本都已驗證。
