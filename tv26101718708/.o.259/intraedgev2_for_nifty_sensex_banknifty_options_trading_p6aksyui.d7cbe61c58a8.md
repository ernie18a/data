以下判斷皆逐根在收盤確認後計算，datetime 只用來辨識日內換日時重置累計值。

一、RMI 常規背離（做空 / 做多）
- RMI：up = RMA(max(close − close[3], 0), 14)，dn = RMA(max(close[3] − close, 0), 14)。dn=0 時 RMI=100，up=0 時 RMI=0，其餘 RMI = 100 − 100/(1+up/dn)。
- 樞紐：用左 5、右 3 根的 pivothigh / pivotlow，分別對 high、low 和 RMI 計算。
  - 記下最近一個價格樞紐高（價格）和最近一個 RMI 樞紐高（RMI 值，≥70 視為超買樞紐）。
  - 記下最近一個 RMI≥70 的樞紐（超買樞紐）的 high 價、RMI 與 bar 序號。
  - 低點側同理：最近的樞紐低，以及 RMI≤30 的超買對應超賣樞紐。
- 近端極值：取最近 4 根的 highest(high)、highest(RMI) 和 lowest(low)、lowest(RMI)。
- 近端高點條件 A：最近 4 根 highest(high) > 最近價格樞紐高，且最近 4 根 highest(RMI) < 最近 RMI 樞紐高，且（該 RMI 樞紐 ≥70 或最近 4 根 highest(RMI) ≥70）。
- 近端高點條件 B：最近 4 根 highest(high) > 最近超買樞紐的價格，且最近 4 根 highest(RMI) < 該樞紐的 RMI，且最近 4 根 RMI 高點發生在該超買樞紐之後。
- 做空：A 或 B 成立，且 RMI 斜率剛翻空，即 RMI < RMI[1] 而前一根 RMI 未下降（RMI[1] ≥ RMI[2]）。
- 做多：把方向全部反過來。比較最近 4 根 lowest(low) < 最近價格樞紐低，且 lowest(RMI) > 最近 RMI 樞紐低，且（該樞紐 ≤30 或 lowest(RMI) ≤30）。超賣樞紐的對應條件 B 同理。RMI 斜率剛翻多，即 RMI > RMI[1] 而前一根 RMI 未上升。

二、合成 CVD 背離（做空 / 做多）
- delta = volume × (2·close − high − low) / (high − low)。high=low 時，若 volume>0，delta = volume × sign(close − close[1])。cumDelta 每日重置後累加 delta。
- 每當 low == lowest(low,5) 就記下當時的 cumDelta 作為 pivot_low_cvd；每當 high == highest(high,5) 就記下 pivot_high_cvd。
- 做多：low == lowest(low,5)，且 low < low[5]，且 cumDelta > pivot_low_cvd[5]，且 close > (high+low)/2。
- 做空：high == highest(high,5)，且 high > high[5]，且 cumDelta < pivot_high_cvd[5]，且 close < (high+low)/2。

三、VWAP 站回 / 跌破及回測
- VWAP = 每日累計 Σ(typical×volume) / Σvolume，typical=(high+low+close)/3，每日重置。ATR=14 期。volSMA=SMA(volume,20)。
- 站回分數 = (volume>1.5×volSMA ? 2:0) + ((close−open)/(high−low)>0.7 ? 1:0) + (RMI>50 且 RMI 連 3 根上升 ? 1:0)。
- 跌破分數 = (volume>1.5×volSMA ? 2:0) + ((open−close)/(high−low)>0.7 ? 1:0) + (RMI<50 且 RMI 連 3 根下降 ? 1:0)。
- 做多（站回）：close>VWAP，close[1]<VWAP[1] 且 close[2]<VWAP[2]，站回分數≥3，且實體在 VWAP 之上的比例≥80%。
- 做空（跌破）：close<VWAP，close[1]>VWAP[1] 且 close[2]>VWAP[2]，跌破分數≥3，且實體在 VWAP 之下的比例≥80%。
- 回測做多：站回後尚未回測過，本根不是站回根，low 在 VWAP±0.2×ATR 內，close>VWAP，且實體在 VWAP 之上的比例≥50%。
- 回測做空：跌破後尚未回測過，本根不是跌破根，high 在 VWAP±0.2×ATR 內，close<VWAP，且實體在 VWAP 之下的比例≥50%。

四、巢狀壓縮（連續三根逐根內縮且同色）
- 做空：連續三根 K 棒，後一根的 high 低於前一根的 high、low 高於前一根的 low，且實體逐根縮小，三根皆收黑（close<open）。
- 做多：同樣的內縮條件，三根皆收紅（close>open）。

五、Doji 影線型態（用 K 棒本身計算，實體/全幅 < 0.25）
- 做空（墓碑）：上影線 > 全幅 60%，下影線 < 全幅 15%。
- 做多（蜻蜓）：下影線 > 全幅 60%，上影線 < 全幅 15%。

六、FVG（三根 K 棒缺口）
- 做多：low > high[2] 且 close[1] > open[1]。缺口區為 high[2] 到 low。
- 做空：high < low[2] 且 close[1] < open[1]。缺口區為 high 到 low[2]。

七、W / M 雙底雙頂
- W（做多）：前根 low[1] 與上一個記錄的擺動低點差距 ≤ 0.15×ATR，間隔至少 max(12, 90/週期分鐘) 根且不超過 240/週期分鐘 根。本根 low > low[1]，且 low[2] > low[1]。另外 low[1] 需靠近昨日 high/low 或 VWAP（≤0.2×ATR）。同時要有任一確認：low[1] 靠近 VWAP−1σ（≤0.25×ATR）、RMI[1] 比上一個低點的 RMI 高 3 以上、或 low[1] 靠近當日成交量剖面的 POC（≤0.25×ATR）。
- M（做空）：條件反向。high[1] 與上一個擺動高點差距 ≤ 0.15×ATR，本根 high < high[1]，high[2] < high[1]，high[1] 靠近 VWAP+1σ，或 RMI[1] 比上一個高點的 RMI 低 3 以上。