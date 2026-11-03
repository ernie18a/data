Calculation: EMA trend score = 60 if close > fast EMA and fast EMA > slow EMA; otherwise 30 if either comparison is true; otherwise 0
Calculation: Momentum score = 20 if RSI is between 50 and 70; otherwise 10 if RSI is above 70 or between 30 and 50; otherwise 0
Calculation: Volume ratio = volume / simple moving average of volume
Calculation: Volatility score = 20 if ATR / close × 100 is within the configured minimum and maximum; otherwise 0
Calculation: Trend slope score = 20 if the current linear regression value of close is greater than its previous-bar value, -20 if lower, otherwise 0
Calculation: Structure score = 20 if close is above the latest confirmed pivot high, -20 if below the latest confirmed pivot low; otherwise 15 if low is above the latest confirmed pivot low and that pivot low is above its value 10 bars earlier; otherwise -15 if high is below the latest confirmed pivot high and that pivot high is below its value 10 bars earlier; otherwise 0. Confirm pivots using equal left and right lookbacks.
Calculation: Bull score = clamp(EMA trend score + max(Trend slope score, 0) + Momentum score + volume score + Volatility score + max(Structure score, 0), 0, 100), where volume score is 20 when volume ratio is at least its configured minimum, otherwise 0
Calculation: Bear score = clamp(100 - EMA trend score + max(-Trend slope score, 0) + 20 - Momentum score + volume score + Volatility score + max(-Structure score, 0), 0, 100)
Long: Bull score >= configured long threshold
Short: Bear score <= configured short threshold
Exit: Long, low <= entry price - entry ATR × configured stop multiple OR high >= entry price + entry ATR × configured target multiple
Exit: Short, high >= entry price + entry ATR × configured stop multiple OR low <= entry price - entry ATR × configured target multiple