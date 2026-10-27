只有 FU 掃流動性 K 棒能由單一商品的 OHLCV 重現，且每根收盤 K 棒才判斷。做多和做空互為鏡像，沒有出場判斷。

共用指標：
- ATR = 14 期 Wilder ATR（RMA）。
- 振幅 rng = high - low。
- 實體 body = |close - open|。
- prevHigh、prevLow = 前一根的 high、low。
- prevBodyTop、prevBodyBot = max、min(前一根 open, 前一根 close)。

做多（出現多方 FU，三級都指向做多）：
- 掃低：low < prevLow，且 prevLow - low >= 0 × ATR。
- 振幅過濾：rng >= 0.5 × ATR。
- 實體過濾：rng > 0 且 body / rng >= 30%。
- 下影線過濾：min(open, close) - low >= 0.15 × body。
- 收盤位置：(close - low) / rng >= 55%。
- 方向：close > open。
- 以上全部成立才算基本條件成立。
- 可選的趨勢過濾，預設關閉：順勢模式要求 close > SMA(close, 50)；逆勢模式要求 close < SMA(close, 50)。
- 可選的布林過濾，預設關閉：low < 布林下軌，其中布林為 SMA20 ± 2 倍標準差。
- 弱級（AFU）：基本條件成立，且 close > prevBodyTop。
- 標準級（FU）：基本條件成立，且 close > prevHigh。
- 強級（SFU）：FU 成立，且 low < 前 5 根（不含當根）的最低 low，且 rng >= 1.2 × ATR。
- 三級任一成立，當根收盤就做多。

做空（空方 FU，鏡像）：
- 掃高：high > prevHigh，且 high - prevHigh >= 0 × ATR。
- 振幅過濾：rng >= 0.5 × ATR。
- 實體過濾：body / rng >= 30%。
- 上影線過濾：high - max(open, close) >= 0.15 × body。
- 收盤位置：(high - close) / rng >= 55%。
- 方向：close < open。
- 可選的趨勢過濾，預設關閉：順勢模式要求 close < SMA50；逆勢模式要求 close > SMA50。
- 可選的布林過濾，預設關閉：high > 布林上軌。
- 弱級（AFU）：基本條件成立，且 close < prevBodyBot。
- 標準級（FU）：基本條件成立，且 close < prevLow。
- 強級（SFU）：FU 成立，且 high > 前 5 根（不含當根）的最高 high，且 rng >= 1.2 × ATR。
- 三級任一成立，當根收盤就做空。