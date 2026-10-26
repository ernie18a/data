判斷只在每根較高週期（delta 週期，例如 30 分 K，由數根回測 K 棒組成）收完時評估一次。沒有明確出場規則，只有做多與做空訊號。

【指標計算】
1. 每根 K 棒的帶號成交量：close>open 為 +volume；close<open 為 -volume；close==open 時，close>前一根 close 為 +volume，close<前一根 close 為 -volume，否則為 0。
2. D（該高週期 K 的 delta）：該 K 內所有棒的帶號成交量加總。prevD 是前一根已完成高週期 K 的 D。
3. chg（價格變化）：該 K 最後一根的 close 減第一根的 open。
4. tol（持平容忍）：24 個最小跳動單位（依高週期大小調整）。
5. avgAbs：最近 8 根已完成高週期 K（含剛完成這根）的 |D| 平均值。

【做空】
- 翻負（flip）：prevD>0 且 D<0 且 chg >= -tol。
- 背離（divergence）：chg>tol 且 D<0，並且不符合上面的翻負條件。
- 吸收（absorption）：avgAbs>0，|D| >= 1.5×avgAbs，|chg|<=tol，且 D>0（大量買 delta 但價格沒動，視為被吸收）。

【做多】
- 翻正（flip）：prevD<0 且 D>0 且 chg <= tol。
- 背離（divergence）：chg<-tol 且 D>0，並且不符合上面的翻正條件。
- 吸收（absorption）：avgAbs>0，|D| >= 1.5×avgAbs，|chg|<=tol，且 D<0（大量賣 delta 但價格沒動）。

同一根 K 可能同時符合吸收與翻轉或背離，這時方向可能衝突，需自行決定優先順序。