【預設組合】主訊號為 Range Filter，另加 RQK 確認。

1. Range Filter（預設類型，source=close）
- r = EMA(EMA(|close-close[1]|,100),199)*3。
- 濾線 f 的更新：若 close>f[1]，則 f=(close-r<f[1] ? f[1] : close-r)；否則 f=(close+r>f[1] ? f[1] : close+r)。
- f 比前一根高則 up 計數加 1，比前一根低則 up 歸 0，相等則維持。down 計數反向計算。
- 主多：close>f 且 up>0。主空：close<f 且 down>0。

2. RQK 確認（預設開啟）
- yhat = Σ close[i]*w / Σ w，i 取 0..26，w=(1+i²/(2*8*8²))^-8。
- 多：yhat>yhat[1]。空：yhat<yhat[1]。

3. 組合與進出場
- 多單條件成立 = 主多 且 所有啟用的確認皆為多。空單條件成立 = 主空 且 所有啟用的確認皆為空。
- 到期過濾：主多（或主空）連續成立的根數（含當根）必須 ≤3，才算有效。
- 輪替：每根先更新狀態，多單條件有效則狀態=多，空單條件有效則狀態=空，否則沿用前一根的狀態。
- 做多訊號 = 多單條件有效，且前一根狀態為空。做空訊號 = 空單條件有效，且前一根狀態為多。狀態初始為 0，所以第一個有效條件只用來設定狀態，不進場。
- 出現做多訊號時：先平空單，再開多單。出現做空訊號時：先平多單，再開空單。反向訊號就是出場。

4. 其他可作主訊號或確認的方向判斷（預設不啟用）。除另有說明，多空互為相反。
- EMA 濾網：close>EMA(200) 為多，close<EMA(200) 為空。
- 2 EMA：EMA50 上穿 EMA200 為多，下穿為空。
- 3 EMA：EMA9>EMA21>EMA55 為多，反向排列為空。
- SuperTrend（hl2±3*ATR(10)）：趨勢=1 為多，否則為空。
  - 下軌 = hl2-3*ATR；若 close[1]>下軌[1]，下軌取 max(下軌, 下軌[1])。
  - 上軌 = hl2+3*ATR；若 close[1]<上軌[1]，上軌取 min(上軌, 上軌[1])。
  - 趨勢=-1 且 close>上軌[1]，轉為 1。趨勢=1 且 close<下軌[1]，轉為 -1。
- ROC(9)：>0 為多，<0 為空。
- MACD(12,26,9)：MACD>signal 為多，<signal 為空。零軸版本另加 MACD>0（空為 <0）。
- RSI(14)：
  - RSI>RSI 的 SMA(14) 為多，< 為空。
  - 離開超賣區：RSI>20 且前一根 RSI<20 為多。離開超買區：RSI<80 且前一根 RSI>80 為空。
  - RSI>50 為多，<50 為空。
- RSI 限制：多單要求 RSI≥40，空單要求 RSI≤60。RSI 均線同樣限制 ≥40（多）、≤60（空）。RSI 均線方向：多單要求 ≥前一根，空單要求 ≤前一根。
- Stochastic(14,3,3)：
  - K 上穿 D 為多，下穿為空。
  - 或在 K 前一根<20、D 之上且現在 K>20 時為多；在 K 前一根>80、D 之下且現在 K<80 時為空。
  - 或 K>D 為多，K<D 為空。
- TSI(25,13,13)：TSI>其 EMA13 訊號線為多，< 為空。零軸版本另加 TSI>0（空為 <0）。
- CCI(20, hlc3)：>100 為多，<-100 為空。
- McGinley Dynamic(14)：close>MG 為多，<MG 為空。
- DPO(10)：close-SMA(10)[6]>0 為多，<0 為空。
- VWAP：close>VWAP 為多，< 為空。
- Awesome Oscillator：SMA(hl2,5)-SMA(hl2,34)>0 為多，<0 為空。
- Donchian(15)：close>前 15 根最高價，趨勢變 1（多）；close<前 15 根最低價，趨勢變 -1（空）；其餘沿用前一個趨勢。
- Chandelier Exit(22,3)：
  - 多方停損 = 22 根最高 close-3*ATR，空方停損 = 22 根最低 close+3*ATR，兩者皆取棘輪式。
  - 方向：close>前一根空方停損則為多，close<前一根多方停損則為空，其餘沿用前一個方向。
- PSAR(0.02,0.02,0.2)：SAR<close 為多，SAR>close 為空。
- SSL(10)：close>SMA(high,10) 則 Hlv=1，close<SMA(low,10) 則 Hlv=-1，否則沿用。Hlv>0 為多，Hlv<0 為空。
- Chaikin Money Flow(20)：>0 為多，<0 為空。
- Wolfpack：EMA3(close)-EMA8(close) 的差值，>0 為多，<0 為空。
- Vortex(14)：VI+>VI- 為多，VI+<VI- 為空。
- Hull MA(55)：HMA>HMA[2] 為多，< 為空。
- DMI(DI 長度 10，ADX 平滑 5)：+DI>-DI 且 ADX≥20 為多，+DI<-DI 且 ADX≥20 為空。僅 ADX 模式為 ADX>20。
- Volatility Oscillator：(close-open) 大於其 100 期標準差為多，小於負的標準差為空。
- Choppiness(14)<61.8 時才允許多空（過濾）。
- Damiani 波動：ATR13/ATR40 加 0.5*(前一根值-前三根值)，再與 threshold(1.4)-STD20/STD100 比較。vol>該值時，多空皆允許（過濾）。
- Volume：volume>SMA(volume,20) 時，多空皆允許（過濾）。
- 其他以 true/false 判斷方向的指標：QQE Mod、B-Xtrender、Bull Bear Power、TDFI、BB Oscillator、WAE、STC、Ichimoku、SuperIchi。
  - STC：STC≥75 為多，≤25 為空。
  - TDFI：>0.05 為多，<-0.05 為空。