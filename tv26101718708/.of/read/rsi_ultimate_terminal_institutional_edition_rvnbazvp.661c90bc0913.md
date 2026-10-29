Calculation: RSI = Relative Strength Index of close
Calculation: RSI EMA = Exponential moving average of RSI
Calculation: RSI slope = RSI minus RSI from a longer lookback ago
Calculation: Adaptive adjustment = minimum of 8 and 0.35 times the standard deviation of RSI over the RSI lookback
Calculation: Dynamic lower zone = maximum of 10 and base lower level minus adaptive adjustment
Calculation: Dynamic upper zone = minimum of 90 and base upper level plus adaptive adjustment
Calculation: Trend EMA = Exponential moving average of close over a longer lookback
Calculation: Average volume = Simple moving average of volume over a lookback
Long: (RSI <= dynamic lower zone AND RSI crosses above RSI EMA AND RSI slope > 0 AND RSI > previous RSI) OR (RSI > mid level AND RSI crosses above RSI EMA AND RSI slope > 0 AND RSI > RSI EMA) AND close > trend EMA AND volume > average volume
Short: (RSI >= dynamic upper zone AND RSI crosses below RSI EMA AND RSI slope < 0 AND RSI < previous RSI) OR (RSI < mid level AND RSI crosses below RSI EMA AND RSI slope < 0 AND RSI < RSI EMA) AND close < trend EMA AND volume > average volume
Exit: long, RSI > mid level AND RSI crosses below RSI EMA AND RSI slope < 0
Exit: short, RSI < mid level AND RSI crosses above RSI EMA AND RSI slope > 0