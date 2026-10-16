# libscws C API

libscws 提供中文分詞、詞典載入與詞語統計。先依 [安裝說明](INSTALL.md)安裝核心，再包含 `<scws/scws.h>` 並連結 `-lscws`。公開宣告以 [scws.h](libscws/scws.h) 為準。

## 最小範例

以下程式接收 UTF-8 XDB 詞典與 UTF-8 規則檔路徑，存成 `segment.c`：

```c
#include <stdio.h>
#include <string.h>
#include <scws/scws.h>

int main(int argc, char **argv)
{
    const char *text = "中文分詞測試";
    scws_t s;
    scws_res_t batch, word;

    if (argc != 3) {
        fprintf(stderr, "Usage: %s dict.utf8.xdb rules.utf8.ini\n", argv[0]);
        return 2;
    }
    s = scws_new();
    if (s == NULL) {
        return 1;
    }
    scws_set_charset(s, "utf8");
    if (scws_set_dict(s, argv[1], SCWS_XDICT_XDB) < 0) {
        scws_free(s);
        return 1;
    }
    scws_set_rule(s, argv[2]);
    if (s->r == NULL) {
        scws_free(s);
        return 1;
    }
    scws_send_text(s, text, (int) strlen(text));
    while ((batch = scws_get_result(s)) != NULL) {
        for (word = batch; word != NULL; word = word->next) {
            printf("%.*s\n", (int) word->len, text + word->off);
        }
        scws_free_result(batch);
    }
    scws_free(s);
    return 0;
}
```

使用預設安裝位置編譯及執行：

```sh
cc -Wall -Wextra -I/usr/local/include segment.c -L/usr/local/lib -lscws -o segment
./segment /usr/local/etc/dict.utf8.xdb /usr/local/etc/rules.utf8.ini
```

可先依 [詞典轉換說明](docs/DICTIONARIES.md)產生測試用 XDB。若核心裝在其他 prefix，請調整 include、library 與執行時函式庫搜尋路徑。

## 資源與記憶體

| 型別 | 用途 | 釋放方式 |
| --- | --- | --- |
| `scws_t` | 分詞實例，由 `scws_new()` 或 `scws_fork()` 建立 | `scws_free()` |
| `scws_res_t` | 一批分詞結果的鏈結串列 | `scws_free_result()` |
| `scws_top_t` | 詞語統計的鏈結串列 | `scws_free_tops()` |

不要直接複製 `struct scws_st`。分詞結果的 `off` 與 `len` 以位元組計算，文字內容需從原輸入切取。

`scws_send_text()` 借用輸入緩衝區，不複製文字。呼叫端需讓該緩衝區在讀取分詞／統計期間保持有效且內容不變。再次送入文字會取代先前設定；不要在一段文字的讀取迴圈中替換輸入。

`scws_result` 包含 `off`、`len`、`idf`、`attr[3]`、`next`。`scws_topword` 包含 `word`、`weight`、`times`、`attr[2]`、`next`；統計結果的 attr 不保證以 NUL 結尾，列印時應限制為兩個字元。

## 建立與設定

| 函式 | 說明 |
| --- | --- |
| `scws_t scws_new()` | 建立實例，失敗回傳 NULL |
| `scws_t scws_fork(scws_t s)` | 建立獨立分詞狀態，透過引用共享詞典與規則；失敗回傳 NULL |
| `void scws_free(scws_t s)` | 釋放實例及其持有的詞典／規則引用 |
| `void scws_set_charset(scws_t s, const char *cs)` | 設定 utf8 或 gbk，預設 gbk；無法辨識時使用 gbk |
| `int scws_set_dict(scws_t s, const char *path, int mode)` | 清除並設定詞典；成功為 0，失敗為 -1 |
| `int scws_add_dict(scws_t s, const char *path, int mode)` | 加入較高優先序詞典；成功為 0，失敗為 -1 |
| `void scws_set_rule(scws_t s, const char *path)` | 取代規則；以 s->r 是否為 NULL 檢查載入結果 |

詞典模式為 `SCWS_XDICT_XDB`、`SCWS_XDICT_TXT`，可搭配 `SCWS_XDICT_MEM`；組合時使用 `|`。載入文字詞典前先設定編碼。

`scws_fork()` 提供獨立分詞狀態；並行使用時，每個執行緒應持有自己的實例。不要同時修改或操作同一實例。

## 分詞選項

| 函式 | 說明 |
| --- | --- |
| `scws_set_ignore(s, yes)` | 1 表示略過標點，0 表示保留 |
| `scws_set_multi(s, mode)` | 設定複合分詞模式 |
| `scws_set_duality(s, yes)` | 是否將零散單字作二字聚合 |
| `scws_set_debug(s, yes)` | 除錯輸出，需以 --enable-debug 建置才有效 |

C 的複合分詞模式使用 `SCWS_MULTI_NONE`、`SCWS_MULTI_SHORT`、`SCWS_MULTI_DUALITY`、`SCWS_MULTI_ZMAIN`、`SCWS_MULTI_ZALL`，以 `|` 組合。請使用 C 標頭檔中的常數；C 模式的位元位置與 PHP／CLI 的 0–15 數值不同。

## 分詞與統計

| 函式 | 說明 |
| --- | --- |
| `void scws_send_text(scws_t s, const char *text, int len)` | 指定文字與位元組長度 |
| `scws_res_t scws_get_result(scws_t s)` | 取得一批結果；需循環呼叫至 NULL |
| `void scws_free_result(scws_res_t result)` | 釋放整批結果，以該批鏈結串列的頭節點作參數 |
| `scws_top_t scws_get_tops(scws_t s, int limit, char *attr)` | 取得依權重排序的詞語統計；limit <= 0 時使用 10 |
| `scws_top_t scws_get_words(scws_t s, char *attr)` | 取得符合詞性條件的詞語統計 |
| `int scws_has_word(scws_t s, char *attr)` | 是否包含符合詞性條件的詞，回傳 1 或 0 |
| `void scws_free_tops(scws_top_t tops)` | 釋放統計結果 |

`scws_get_tops()` 與 `scws_get_words()` 沒有結果時回傳 NULL，這兩個函式的 `attr` 為 NULL 表示不篩選。`scws_has_word()` 請明確提供詞性條件。`n,v` 表示包含指定詞性，`~n,v` 表示排除。原始文字、詞典與規則必須使用相同編碼；統計內容依詞典與規則而定。

PHP 介面另見 [PHP API](phpext/README.md)，核心版本以已安裝標頭檔中的 `SCWS_VERSION` 為準。
