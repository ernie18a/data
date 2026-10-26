# 產物使用規則

## 檔案
- `.o/*.md`：原始策略判斷邏輯摘要，每行一條規則，格式「類型：內容」。
- `.o/.table/rules.tsv`：每列一條規則行，欄位定義見 `.o/.table/schema.md`。TSV、有表頭、無引號；多選欄以 `|` 連接；不適用為 `null`。
- `.o/.table/report.md`：建表的覆蓋數與檢查結果。
- `.o/.sort/`、`.o/.pair/`、`.o/.run/`（若存在）：`groups.tsv`（原檔名、行號、群組代號、判定依據）與群組說明。

## 讀取方式
- Python：`csv.DictReader(open(p), delimiter='\t', quoting=csv.QUOTE_NONE)`。
- 例：做多行中以交叉觸發者 `awk -F'\t' 'NR>1 && $3=="做多" && $6=="cross"' rules.tsv`。

## 後續對話規則
- 問題牽涉全體時，以程式查詢產物作答。
- 回答附覆蓋數，包含納入的檔案數與規則行數。
- 需要語意判斷時，把查出的全部列分批逐一處理，每批 100 列以內。
