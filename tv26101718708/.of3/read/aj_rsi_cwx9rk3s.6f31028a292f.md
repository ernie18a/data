Calculation: T1 RSI = RSI(close, RSI lookback) on T1 bars, sampled on chart bars using the T1 bar still forming
Calculation: RSI moving average = MA(T1 RSI, MA lookback, MA type) on T1 bars, sampled on chart bars using the T1 bar still forming
Calculation: Mansfield RS = ((close / benchmark close) / SMA(close / benchmark close, RS lookback) - 1) * 100
Calculation: RS state = neutral initially; set bullish when Mansfield RS crosses above 0, set bearish when it crosses below 0, otherwise retain the prior state
Long: Mansfield RS crosses above 0 OR T1 RSI crosses above mid-level OR T1 RSI crosses above upper-level OR RS state = bullish OR (RS state = neutral AND T1 RSI > RSI moving average)
Short: Mansfield RS crosses below 0 OR T1 RSI crosses below mid-level OR T1 RSI crosses below lower-level OR RS state = bearish OR (RS state = neutral AND T1 RSI <= RSI moving average)