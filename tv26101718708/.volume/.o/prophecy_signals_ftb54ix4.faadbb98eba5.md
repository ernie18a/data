Calculation: volume spike = volume > simple moving average of volume × volume spike multiplier
Calculation: money flow volume = ((close − low) − (high − close)) / (high − low) × volume
Calculation: Chaikin money flow = simple moving average of money flow volume / simple moving average of volume, using the same lookback for both
Calculation: candle body = absolute value of close − open
Calculation: candle range = high − low
Long: (previous candle close < previous candle open AND close > open AND close > previous candle open AND open ≤ previous candle close AND volume spike AND RSI < overbought threshold) OR (close > open AND candle body > ATR × momentum multiplier AND volume spike AND close > fast EMA AND close > mid EMA)
Short: (previous candle close > previous candle open AND close < open AND close < previous candle open AND open ≥ previous candle close AND volume spike AND RSI > oversold threshold) OR (close < open AND candle body > ATR × momentum multiplier AND volume spike AND close < fast EMA AND close < mid EMA)