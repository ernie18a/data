Calculation: Moving average = selected SMA, EMA, WMA, VWMA, or HMA of close over its lookback
Calculation: Deviation = standard deviation of close over its lookback × multiplier
Calculation: Upper/lower band = moving average ± deviation
Calculation: RSI = relative strength index of close over its lookback
Calculation: Bandwidth = upper band − lower band
Calculation: High/low volatility threshold = 2000-bar simple moving average of bandwidth × (1 ± volatility factor / 10)
Calculation: ATR = average true range over its lookback
Calculation: Long trailing stop = highest of the prior trailing stop and the lowest low over its lookback minus ATR × multiplier
Calculation: Short trailing stop = lowest of the prior trailing stop and the highest high over its lookback plus ATR × multiplier
Long: open < lower band AND close > lower band AND RSI crossed above its neutral level within its lookback AND bandwidth is at or below the high-volatility threshold AND at or above the low-volatility threshold
Short: open > upper band AND close < upper band AND RSI crossed below its neutral level within its lookback AND bandwidth is at or below the high-volatility threshold AND at or above the low-volatility threshold
Exit: Long, low <= active stop level OR (take profit enabled AND high >= saved take-profit level) OR an opposing short signal starts a new trade direction
Exit: Short, high >= active stop level OR (take profit enabled AND low <= saved take-profit level) OR an opposing long signal starts a new trade direction