以下判斷皆逐根在收盤計算，訊號指向做多或做空，反向訊號出現時平倉反手。不同指標同時出現反向訊號時，空方優先。

1. 布林式通道（通道 = ALMA 加減 2 倍標準差）：
- ALMA = ALMA(close, 40, offset 0.85, sigma 6)，sd = stdev(close, 40)。
- close > ALMA + 2*sd → 做空。
- close < ALMA - 2*sd → 做多。

2. MACD 零軸：
- MACD 線 = EMA12(close) - EMA26(close)。
- MACD 線由上往下穿越 0 → 做空。
- MACD 線由下往上穿越 0 → 做多。

3. 隨機 RSI：
- r = RSI(close, 24)，k = SMA(stoch(r, r, r, 24), 3)，d = SMA(k, 3)。
- k 由上往下穿越 d 且 k > 80 → 做空。
- k 由下往上穿越 d 且 k < 20 → 做多。

4. 異常量錨點共識（CVD、OBV、RSI、MACD、Aroon 各自獨立判斷）：
- 量能異常：z = (volume - SMA(volume, 24)) / stdev(volume, 24)，z > 2.5 即為異常量。
- 錨點：每遇異常量，就把當根的指標值推入該指標的佇列，保留最近 24 筆，初始值為 0。
- 當根若為異常量，先更新佇列再投票，因此當根自己的錨點也會參與。
- 有效錨點 = 值不為 0 的錨點（以 CVD 佇列判斷，其他指標沿用同一個有效數 valid）。
- 門檻 T = max(1, floor(valid * 0.75))，valid 為 0 時不產生訊號。
- 指標定義：
  - CVD = 累計（陽線 +volume、陰線 -volume、平盤 0）。
  - OBV = ta.obv。
  - MACD = 上述 MACD 線。
  - Aroon 差 = Aroon 上 - Aroon 下，其中 Aroon 上 = 100*(24 + highestbars(high, 24))/24，Aroon 下 = 100*(24 + lowestbars(low, 24))/24。
- 對每個有效錨點 a，令 diff = 指標現值 - a，ch = 指標現值 - 前一根值。
- CVD、OBV、MACD、Aroon 差：
  - ch < 0 且 diff > 0 的錨點數 >= T → 做空。
  - ch > 0 且 diff < 0 的錨點數 >= T → 做多。
- RSI：令 r24 = RSI(close, 24)，diff = r24 - 錨點的 r24，prevdiff = 前一根 r24 - 錨點的 r24。
  - prevdiff > 15 且 diff <= 15 的錨點數 >= T → 做空。
  - prevdiff < -15 且 diff >= -15 的錨點數 >= T → 做多。

以上任一項觸發即為該方向訊號，該方向持續到出現反向訊號。