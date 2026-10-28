Calculation: EMA distance (%) = absolute difference between the shorter-lookback and longer-lookback EMAs, divided by close and multiplied by 100
Calculation: VWAP z-score = (close − current-session VWAP) / rolling standard deviation of (hlc3 − current-session VWAP)
Calculation: Long stop = entry price − ATR × risk multiplier
Calculation: Long target = entry price + (entry price − long stop) × reward/risk ratio
Calculation: Short stop = entry price + ATR × risk multiplier
Calculation: Short target = entry price − (short stop − entry price) × reward/risk ratio
Long: (ADX > trend threshold AND EMA distance (%) > distance threshold AND shorter-lookback EMA > longer-lookback EMA AND close > highest high over the breakout lookback, excluding the current bar) OR (ADX < range threshold AND VWAP z-score < −mean-reversion threshold AND close > previous close); current signal is long and previous bar's signal was not long; position is flat or short
Short: (ADX > trend threshold AND EMA distance (%) > distance threshold AND shorter-lookback EMA < longer-lookback EMA AND close < lowest low over the breakout lookback, excluding the current bar) OR (ADX < range threshold AND VWAP z-score > mean-reversion threshold AND close < previous close); current signal is short and previous bar's signal was not short; position is flat or long
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target