Calculation: RSI = Relative Strength Index of close
Calculation: Money Flow Index = MFI of typical price (high + low + close) / 3 and volume
Calculation: Up/down volume ratio = sum of volume on bars where close > open over a lookback divided by sum of volume on bars where close < open over the same lookback; use the up-volume sum if the down-volume sum is zero
Calculation: Volume ratio = volume / simple moving average of volume over a longer lookback
Calculation: Bull flow score = 20 if RSI > its bullish threshold, plus 20 if MFI > its bullish threshold, plus 20 if up/down volume ratio > its bullish threshold, plus 20 if close > a longer-lookback simple moving average of close, plus 20 if close has risen for a shorter lookback
Calculation: Bear flow score = 20 if RSI < its bearish threshold, plus 20 if MFI < its bearish threshold, plus 20 if up/down volume ratio < its bearish threshold, plus 20 if close < a longer-lookback simple moving average of close, plus 20 if close has fallen for a shorter lookback
Calculation: Flow score = bull flow score − bear flow score
Calculation: Bullish pressure = exponential moving average of 14-bar-smoothed positive RSI pressure, where positive RSI pressure = max(RSI − 50, 0) / 50 × 100
Calculation: Volume run rate = (volume ratio − 1) × 100
Long: low = lowest low over a lookback AND RSI > lowest RSI over the same lookback AND RSI 14 bars ago = lowest RSI over the same lookback
Long: bullish pressure > its expansion threshold AND volume run rate > its expansion threshold AND the preceding bar did not meet both conditions
Long: flow score > its threshold AND prior-bar flow score ≤ its threshold
Long: close > VWAP
Long: up/down volume ratio ≥ its bullish threshold
Long: RSI > its bullish threshold AND MFI > its bullish threshold
Short: high = highest high over a lookback AND RSI < highest RSI over the same lookback AND RSI 14 bars ago = highest RSI over the same lookback
Short: flow score < the negative of its threshold AND prior-bar flow score ≥ the negative of its threshold
Short: close < VWAP
Short: up/down volume ratio ≤ its bearish threshold
Short: RSI < its bearish threshold AND MFI < 50