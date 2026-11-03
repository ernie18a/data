Calculation: Upper EMA envelope = maximum of four chart-timeframe EMAs with progressively longer lookbacks
Calculation: Lower EMA envelope = minimum of four chart-timeframe EMAs with progressively longer lookbacks
Calculation: Tight = upper EMA envelope - lower EMA envelope < a configurable fraction of the width of Bollinger Bands, which use a simple moving average and standard deviation over the same lookback
Calculation: Upper Bollinger Band = simple moving average + configurable multiple of standard deviation, both using the same chart-timeframe lookback
Calculation: Lower Bollinger Band = simple moving average - configurable multiple of standard deviation, both using the same chart-timeframe lookback
Calculation: Daily EMA = EMA of daily closes; compare with the last completed daily close
Calculation: Long profit % = 100 × (close - entry price) / entry price
Calculation: Short profit % = 100 × (entry price - close) / entry price
Calculation: Long trailing drawdown % = 100 × (highest close since long entry - close) / highest close since long entry
Calculation: Short trailing drawdown % = 100 × (close - lowest close since short entry) / lowest close since short entry
Long: last completed daily close > daily EMA
Long: close > upper EMA envelope AND Tight
Long: last completed daily close > daily EMA AND close > upper EMA envelope AND Tight AND volume > its longer-lookback SMA × a configurable factor AND close > open
Long: position is flat AND close > open AND high > upper Bollinger Band
Short: last completed daily close < daily EMA
Short: close < lower EMA envelope AND Tight
Short: last completed daily close < daily EMA AND close < lower EMA envelope AND Tight AND volume > its longer-lookback SMA × a configurable factor AND close < open
Short: position is flat AND close < open AND low < lower Bollinger Band
Exit: Long, long profit % >= configurable take-profit threshold OR trailing stop is enabled and has activated after long profit % reached its activation threshold and long trailing drawdown % >= its retracement threshold OR shortest EMA < next-shortest EMA
Exit: Short, short profit % >= configurable take-profit threshold OR trailing stop is enabled and has activated after short profit % reached its activation threshold and short trailing drawdown % >= its retracement threshold OR shortest EMA > next-shortest EMA