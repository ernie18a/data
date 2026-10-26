以收盤價逐根計算。SMA20、SMA50、SMA200 為收盤價的簡單移動平均。效率比 ER = |close − close[10]| ÷ 最近 10 根 |close − 前一根 close| 的總和，總和為 0 時 ER 取 0。

狀態判斷（ER<0.2 視為雜亂，ER>0.4 視為高品質）：
- SMA50 > SMA200（多頭排列）：
  - ER<0.2 為中性。
  - SMA20 > SMA50 且 close > SMA20：ER>0.4 為「極度偏多」，否則為「偏多」。
  - SMA20 > SMA50 且 close ≤ SMA20 且 close > SMA50：為「回檔」，屬偏多。
  - 其餘為中性。
- SMA50 ≤ SMA200（空頭排列）：
  - ER<0.2 為中性。
  - SMA20 > SMA50 時，close > SMA50 為中性，close ≤ SMA50 為「偏空」。
  - SMA20 ≤ SMA50 時，close < SMA20 且 ER>0.4 為「極度偏空」，否則為「偏空」。

做多：狀態為極度偏多、偏多或回檔。
做空：狀態為極度偏空或偏空。
中性狀態不指向任何方向。