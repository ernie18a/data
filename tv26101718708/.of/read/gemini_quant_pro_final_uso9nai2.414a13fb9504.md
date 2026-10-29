Calculation: Short-lookback EMA = EMA of chart-timeframe close with a shorter lookback than the long-lookback EMA
Calculation: Long-lookback EMA = EMA of chart-timeframe close with a longer lookback than the short-lookback EMA
Calculation: Longer-higher-timeframe trend = close > long-lookback EMA on the last completed bar of a higher timeframe longer than the other trend timeframe
Calculation: Shorter-higher-timeframe trend = close > long-lookback EMA on the last completed bar of a higher timeframe shorter than the other trend timeframe
Calculation: Long stop = entry-signal-bar low × (1 − stop buffer)
Calculation: Short stop = entry-signal-bar high × (1 + stop buffer)
Calculation: Long target = entry-signal-bar close + (entry-signal-bar close − long stop) × target risk multiple
Calculation: Short target = entry-signal-bar close − (short stop − entry-signal-bar close) × target risk multiple
Long: low ≤ short-lookback EMA AND close > short-lookback EMA AND close > long-lookback EMA AND close > long-lookback EMA on the last completed bar of the longer higher timeframe AND close > long-lookback EMA on the last completed bar of the shorter higher timeframe AND volume > 20-bar SMA of volume
Short: high ≥ short-lookback EMA AND close < short-lookback EMA AND close < long-lookback EMA AND close < long-lookback EMA on the last completed bar of the longer higher timeframe AND close < long-lookback EMA on the last completed bar of the shorter higher timeframe AND volume > 20-bar SMA of volume
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target