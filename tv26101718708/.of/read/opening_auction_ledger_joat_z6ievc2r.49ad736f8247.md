Calculation: Opening range high/low = maximum/minimum of high/low (or candle body high/low, according to the selected source) during the configured opening session; lock when that session ends
Calculation: Opening range size = opening range high − opening range low
Calculation: Relative volume = current bar volume / short-lookback moving average of volume
Calculation: Long continuation trail = initialize to close − ATR × multiplier; thereafter the greater of the previous trail and close − ATR × multiplier
Calculation: Short continuation trail = initialize to close + ATR × multiplier; thereafter the lesser of the previous trail and close + ATR × multiplier
Long: opening range is locked AND bar is confirmed AND close > opening range high + opening range size × minimum break fraction AND no breakout is currently active AND (relative volume filter is disabled OR relative volume ≥ threshold)
Short: opening range is locked AND bar is confirmed AND close < opening range low − opening range size × minimum break fraction AND no breakout is currently active AND (relative volume filter is disabled OR relative volume ≥ threshold)
Exit: long, bar is confirmed AND close < long continuation trail
Exit: short, bar is confirmed AND close > short continuation trail