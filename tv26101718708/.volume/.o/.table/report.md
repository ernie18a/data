# /bulk 0 建表報告

## 覆蓋
- 原檔 568 份、規則行 4222 條；rules.tsv 收錄 568 份、4222 列，缺漏 0。
- 原句檢查（程式比對 rules.tsv 每列 text 與原檔同行號內容）：4222／4222 通過，100%。
- 錨點檢查（抽取時抄寫的前 10 字與原檔該行比對，確認行號對齊）：4222／4222 通過。
- 封閉值域外的值：0。
- 原檔中有 3 行只有「做空：」而無內容，表中照原樣保留：long_term_a7ywkoml.7235f84965f0.md:2、sw_sve_stochasticvolemas_sergio_waldoke_gwlzhea5.ee889f04645c.md:5、turks_tiered_unit_risk_kernel_strategy_worximlc.81cec64e646f.md:5。

## 流程
- 抽樣 30 份定義欄位（schema.md），依檔案大小平衡分 16 批交 subagent 抽取。
- build.py 合併、正規化（小寫、多選排序去重、none 與其他值並存時移除 none、非計算行 calc 強制 null、缺欄補 null），寫出 rules.tsv。

