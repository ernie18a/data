# /bulk 1 分類體系歸納報告

## 覆蓋
- 原檔 568 份、規則行 4222 條；groups.tsv 收錄 4222 列，缺漏 0、重複 0、多餘 0（check.json）。
- 拆段後 959 個邏輯段，歸入 53 群（25 個初始葉、24 個全量歸類後新增葉、4 個複審拆出子群），每群皆有說明。

## 流程
- 分類體系：抽 45 份樣本，分 3 步迭代（每步 15 份，獨立 subagent），產出 taxonomy v1→v3。
- 逐份歸類：依檔案大小分 20 批，subagent 逐份拆段、歸葉、標註濾網／出場標籤與小異；放不進者提 NEW 代號（41 個）。
- 新代號合併：41 個 NEW 收斂為 24 個新葉，寫入 taxonomy.md（work/map_new.tsv）。
- 逐群複審：依群切 10 批（每批 ≤100 段，最大群獨立一批），subagent 檢查群內同構、改派或拆子群（46 段），並撰寫群組說明（work/reassign_*.tsv、desc_*.md）。
- merge.py 套用對映與改派，build.py 組裝 groups.tsv、members.tsv、groups.md 並檢查覆蓋。
