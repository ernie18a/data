# /bulk 0 建表報告

## 覆蓋
- 原檔 568 份、規則行 4222 條；rules.tsv 收錄 568 份、4222 列，缺漏 0。
- 原句檢查（程式比對 rules.tsv 每列 text 與原檔同行號內容）：4222／4222 通過，100%。
- 錨點檢查（subagent 抄寫的前 10 字與原檔該行比對，用於確認行號對齊）：4222／4222 通過。
- 封閉值域外的值：0。

## 流程
- 抽樣 30 份定義欄位（schema.md），依檔案大小平衡分 16 批（work/in_XX.tsv），各交一個 subagent 輸出 work/out_XX.tsv。
- build.py 合併、正規化（小寫、多選排序去重、none 與其他值並存時移除 none、非計算行 calc 強制 null、缺欄補 null），並寫 rules.tsv 與 check_<輪>.json。
- 補抽輪數上限 3；實際只跑 2 輪程式檢查，不需重新抽取。

## 失敗與處理
- 7 批 subagent（02、03、04、05、07、09、14）在自查階段遇到 API 速率限制而中止；輸出檔都已寫完，列數與輸入一致，經程式檢查也完整，所以沒有重跑。
- 第 0 輪有 3 列被錨點檢查擋下：原檔中這 3 行內容只有「做空：」，冒號後沒有文字，錨點本來就應該是空的。已修正檢查規則，允許內容為空時錨點為空，第 1 輪全數納入：
  - long_term_a7ywkoml.7235f84965f0.md:2
  - sw_sve_stochasticvolemas_sergio_waldoke_gwlzhea5.ee889f04645c.md:5
  - turks_tiered_unit_risk_kernel_strategy_worximlc.81cec64e646f.md:5

## 一致性抽查
- 做多行的 side 都是 long 或 both、做空行都是 short 或 both、出場行的 exit 都不是 none：違反 0 列。
- 欄位值只經過值域與格式驗證；語意映射正確與否沒有逐列人工複核。
