【指標】ATR13=true range 的 Wilder RMA；ATR14 同法（只用於停損）。基準價=close。bar_index<60 的 bar 不產生任何訊號。通道倍數 m1=4.0、m2=5.0、m3=6.0、m4=7.0。

【趨勢狀態與四條軌道】trend 初值=多(1)。K=1..4：多頭時 upK=close−ATR13×mK，tsK=max(upK, 前一根tsK)（無前值則取upK）；空頭時 loK=close+ATR13×mK，tsK=min(loK, 前一根tsK)（無前值則取loK）。
翻多/翻空：trend=多且 close<前一根ts3 → 翻空，四條軌道重設為 loK；trend=空且 close>前一根ts3 → 翻多，四條軌道重設為 upK。翻轉的那根 bar 記為趨勢起點，barsInTrend=目前 bar 序號−趨勢起點序號。

【做多／做空判斷】
1. 翻多 bar（收盤確認、已過暖機）→ 做多；翻空 bar → 做空。
2. 多頭回測做多：在 trend=多 時，每根 bar 先把 pendingL 減 1（最低為 0，歸 0 時深度歸 0），翻轉 bar 時 pending 與深度全部清 0。再算觸及深度 d：low<=ts4 為4，否則 low<=ts3 為3，否則 low<=ts2 為2，否則 low<=ts1 為1，否則 0。d>0 時 pendingL=8，depthL=max(depthL, d)。當 pendingL>0 且 trend=多 且 close>ts1 且 close>open（reclaim）時計分：
  - 深度分：depthL=2→25，3→18，1→15，4→10。
  - K 線分：CLV=(close−low)/(high−low)（high=low 時取0.5）；>0.7→20，>0.5→12，否則5。
  - 趨勢年齡分：barsInTrend 在10~150→15，<10→8，>150→5。
  - 量能分：若累計成交量>0，volume>前一根的 SMA20(volume)×1.2→20，>前一根SMA20→12，否則5；無成交量資料→12。
  - 偏向分：以前一根 close 與前一根 EMA50(close) 比較，close[1]>EMA50[1] 為偏多，否則偏空（資料缺漏視為中性）。偏多→20，中性→10，偏空→0。
  總分=五項相加，≥80 且距上一次回測訊號≥5根（做多做空共用冷卻，翻轉訊號不更新冷卻）→ 做多。觸發後 pendingL 與 depthL 清0。
3. 空頭回測做空：與上面鏡像。trend=空；d 用 high>=ts4/ts3/ts2/ts1 判斷；reclaim 為 close<ts1 且 close<open；CLV=(high−close)/(high−low)；偏向分在偏空→20，中性→10，偏多→0；其餘計分與門檻、冷卻相同，總分≥80 → 做空。
同一根 bar 只會出現單一方向訊號（翻轉 bar 的回測 pending 已清空）。

【持倉與出場】
- 空手時，訊號方向就進場，進場價=該根 close。持多遇到做空訊號、持空遇到做多訊號 → 先平倉，同一根再反向進場。同向訊號忽略。
- 停損（進場時決定）：多單 SL=min(low−0.25×ATR14, close−0.5×ATR14)；空單 SL=max(high+0.25×ATR14, close+0.5×ATR14)。R=|進場價−SL|，R<=0 不進場。TP1/TP2/TP3=進場價±1R/2R/3R（多加空減）。
- 進場那根 bar 不檢查出場；之後每根 bar 以 bar 開始時的停損值檢查：多單 low<=SL、空單 high>=SL → 出場。
- 多單 high>=TP3、空單 low<=TP3 → 出場。
- 多單 high>=TP1、空單 low<=TP1，且同一根沒有觸發 SL → 標記 TP1 已達，並把 SL 移到進場價（保本）。保本後的新 SL 從下一根 bar 才生效。
- 同一根 bar 同時碰到 SL 與 TP，以 SL 為準。