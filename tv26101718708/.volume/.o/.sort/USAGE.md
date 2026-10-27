# 產物使用規則（.o/.sort：分類體系歸納）

## 檔案
- `.o/*.md`：原始策略判斷邏輯摘要，每行一條規則，格式「類型：內容」。
- `.o/.table/rules.tsv`：建表結果，每列一條規則行，欄位定義見 `.o/.table/schema.md`。
- `.o/.sort/groups.tsv`：每列一條規則行，欄位 file、line、group、basis（判定依據：此行在該邏輯段的角色；複審改派者附理由）。同一行被多段共用時 group 以 `|` 連接。
- `.o/.sort/members.tsv`：每列一個邏輯段（一份檔案可拆成多段），欄位 file、seg、group、summary（段的構成方式）、flt（F. 濾網標籤）、exit（X. 出場標籤）、diff（相對群核心的小異）。
- `.o/.sort/groups.md`：群組說明。總覽表（代號、名稱、檔案數、段數、規則行數）；每群列核心邏輯、可選濾網、出場變體、常見小異與全部成員。以 `## <代號>` 定位。
- `.o/.sort/taxonomy.md`：分類體系（各葉的構成方式、判別準則、歸類決策順序、F./X. 標籤詞彙）。
- `.o/.sort/check.json`：覆蓋檢查結果。
- 代號階層：族（第一段，如 BRK、MA、OSC）→ 葉（族.名）→ 子群（族.名.子名）。查一族用前綴比對。

## 讀取方式
- TSV 有表頭、無引號：`csv.DictReader(open(p), delimiter='\t', quoting=csv.QUOTE_NONE)`。
- 與建表欄位合併：以 (file, line) 連接 `groups.tsv` 與 `.table/rules.tsv`。
- 例：某群的成員段 `awk -F'\t' '$3=="BRK.ORB"' members.tsv`；某族的規則行 `awk -F'\t' 'NR>1 && $3 ~ /^OSC\./' groups.tsv`。

## 後續對話規則
- 問題牽涉全體時，以程式查詢產物作答。
- 回答附覆蓋數，包含納入的檔案數與規則行數。
- 需要語意判斷時，把查出的全部列分批逐一處理，每批 100 列以內。
