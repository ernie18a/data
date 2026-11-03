Calculation: Prior swing low = lowest low over a lookback ending on the previous chart bar.
Calculation: Prior swing high = highest high over a lookback ending on the previous chart bar.
Calculation: Active bearish gap top = low two chart bars ago when the current high is below that low by at least a minimum gap size; each new bearish gap replaces the previous one, and the gap becomes inactive immediately after close exceeds its top.
Calculation: Active bullish gap bottom = high two chart bars ago when the current low is above that high by at least a minimum gap size; each new bullish gap replaces the previous one, and the gap becomes inactive immediately after close falls below its bottom.
Long: Low < prior swing low AND close > prior swing low AND prior swing low - low >= minimum sweep size.
Short: High > prior swing high AND close < prior swing high AND high - prior swing high >= minimum sweep size.
Long: Close > active bearish gap top.
Short: Close < active bullish gap bottom.
Long: Close > EMA of close.
Short: Close <= EMA of close.