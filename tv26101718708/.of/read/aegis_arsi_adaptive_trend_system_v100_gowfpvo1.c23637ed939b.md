Calculation: ARSI = (RMA(diff, lookback) / RMA(abs(diff), lookback)) × 50 + 50, where upper and lower are the highest and lowest close over the lookback, range = upper − lower, and diff = range if upper exceeds its prior value; else −range if lower is below its prior value; else close − prior close
Calculation: Signal = EMA(ARSI, smoothing lookback)
Calculation: Higher-timeframe EMA = EMA of the last completed higher-timeframe close, calculated on chart-timeframe bars
Calculation: Active market = ATR > SMA(ATR, longer lookback)
Calculation: Acceptable candle = high − low ≤ 2.5 × abs(close − open)
Calculation: Long stop = max(initial stop, trailing stop); initialize initial stop at entry price − ATR-at-entry × stop multiple and trailing stop at entry price − ATR-at-entry × trail multiple; each bar update trailing stop to max(previous trailing stop, close − ATR × trail multiple); after high − entry price ≥ ATR × breakeven multiple, set initial stop to entry price × (1 + breakeven offset)
Calculation: Short stop = min(initial stop, trailing stop); initialize initial stop at entry price + ATR-at-entry × stop multiple and trailing stop at entry price + ATR-at-entry × trail multiple; each bar update trailing stop to min(previous trailing stop, close + ATR × trail multiple); after entry price − low ≥ ATR × breakeven multiple, set initial stop to entry price × (1 − breakeven offset)
Long: ARSI > Signal AND prior ARSI ≤ prior Signal AND close > long higher-timeframe EMA AND ARSI ≤ long RSI limit AND ATR > SMA(ATR, longer lookback) AND high − low ≤ 2.5 × abs(close − open) AND cooldown timer = 0 AND position side is flat or short
Short: ARSI < Signal AND prior ARSI ≥ prior Signal AND close < short higher-timeframe EMA AND ARSI ≥ short RSI limit AND ATR > SMA(ATR, longer lookback) AND high − low ≤ 2.5 × abs(close − open) AND cooldown timer = 0 AND position side is flat or long
Exit: long, low ≤ long stop
Exit: short, high ≥ short stop