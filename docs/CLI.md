# 命令列工具

先依 [安裝說明](../INSTALL.md)安裝。預設工具位置為 `/usr/local/bin/`；下方假設該目錄已在 PATH。

## 分詞

```sh
printf '中文分詞測試\n' | scws \
  -c utf8 -d tests/dict.utf8.txt -r /usr/local/etc/rules.utf8.ini -N
```

在解壓後的套件根目錄執行會得到含有 `中文 分詞 測試` 的結果。正式詞典請換成自己的路徑。

讀取檔案並顯示詞性：

```sh
scws -c utf8 -d /usr/local/etc/dict.utf8.xdb \
  -r /usr/local/etc/rules.utf8.ini -A -i input.txt
```

`-i` 可接檔案路徑或文字；省略時逐行讀取標準輸入。`-o` 可指定輸出檔案，但工具會拒絕覆寫既有檔案。

## 常用選項

| 選項 | 用途 |
| --- | --- |
| `-c utf8`／`-c gbk` | 指定編碼，預設 gbk；請放在 -d 之前 |
| `-d path` | 指定 XDB 詞典；副檔名 .txt 會以文字詞典載入 |
| `-d path1:path2` | 載入多個詞典，後面的優先序較高 |
| `-r path` | 指定規則檔 |
| `-i input`、`-o output` | 指定輸入與輸出 |
| `-A` | 顯示詞性 |
| `-I` | 略過標點符號 |
| `-M 1..15` | 複合分詞；1、2、4、8 對應短詞、二元、重要單字、全部單字，可相加組合 |
| `-U` | 零散單字二字聚合 |
| `-E` | 將 XDB 詞典載入記憶體，需放在 -d 之前 |
| `-t count` | 改為輸出關鍵詞統計 |
| `-a 'n,v'`／`-a '~n,v'` | 統計時只包含／排除指定詞性 |
| `-N` | 隱藏耗時與部分提示 |
| `-D` | 除錯模式，需在核心建置時啟用 --enable-debug |
| `-v`、`-h` | 查看版本與完整說明 |

## 關鍵詞統計

```sh
scws -c utf8 -d /usr/local/etc/dict.utf8.xdb \
  -r /usr/local/etc/rules.utf8.ini -t 10 -a 'n,v' -i input.txt
```

詞性、切分方式與統計結果依詞典及規則而定。

## 詞典轉換

在解壓後的套件根目錄，將內附文字詞典轉成測試用 XDB：

```sh
scws-gen-dict -c utf8 -i tests/dict.utf8.txt -o /tmp/scws-test.utf8.xdb
```

再指定該 XDB：

```sh
printf '中文分詞測試\n' | scws \
  -c utf8 -d /tmp/scws-test.utf8.xdb -r /usr/local/etc/rules.utf8.ini -N
```

文字詞典格式與規則檔選擇見 [詞典與規則](DICTIONARIES.md)。完整工具選項可執行 `scws-gen-dict -h` 查看。