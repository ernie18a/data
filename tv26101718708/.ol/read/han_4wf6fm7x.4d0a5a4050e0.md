Calculation: Support = lowest low over the lookback
Calculation: Resistance = highest high over the lookback
Calculation: Bullish pin bar = lower wick ≥ 2 × body AND upper wick ≤ 0.3 × body AND candle range > ATR × range multiplier
Calculation: Bearish pin bar = upper wick ≥ 2 × body AND lower wick ≤ 0.3 × body AND candle range > ATR × range multiplier
Calculation: Bullish engulfing = previous candle bearish AND current candle bullish AND current close > previous open AND current open < previous close
Calculation: Bearish engulfing = previous candle bullish AND current candle bearish AND current close < previous open AND current open > previous close
Calculation: Long stop = previous bar low at entry signal − stop ATR multiple × ATR
Calculation: Long target = entry signal close + reward/risk multiple × (entry signal close − long stop)
Calculation: Short stop = previous bar high at entry signal + stop ATR multiple × ATR
Calculation: Short target = entry signal close − reward/risk multiple × (short stop − entry signal close)
Long: close > short-period SMA AND low ≤ Support × (1 + support tolerance) AND (bullish pin bar OR bullish engulfing) AND close > previous bar high AND (volume filter disabled OR volume ≥ volume multiple × short-period average volume) AND bars since last trade > cooldown
Short: close < short-period SMA AND high ≥ Resistance × (1 − resistance tolerance) AND (bearish pin bar OR bearish engulfing) AND close < previous bar low AND (volume filter disabled OR volume ≥ volume multiple × short-period average volume) AND bars since last trade > cooldown
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target