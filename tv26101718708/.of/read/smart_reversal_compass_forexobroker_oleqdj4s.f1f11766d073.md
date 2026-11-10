Calculation: Confirmed pivot high or low = a high or low at a pivot bar with the same configurable number of bars on each side; it becomes available on the bar that confirms its right side. Keep the two most recent confirmed pivots of each kind, their pivot-bar indices, and RSI at each pivot bar.
Calculation: Bullish divergence = two confirmed pivot lows exist AND current bar index minus the latest pivot-low bar index <= divergence lookback AND latest pivot low < preceding pivot low AND RSI at latest pivot low > RSI at preceding pivot low.
Calculation: Bearish divergence = two confirmed pivot highs exist AND current bar index minus the latest pivot-high bar index <= divergence lookback AND latest pivot high > preceding pivot high AND RSI at latest pivot high < RSI at preceding pivot high.
Calculation: Volume climax = volume >= volume SMA multiplied by a volume multiplier.
Calculation: Bullish reversal candle = (high - low > 0 AND (min(open, close) - low) / (high - low) >= wick-ratio threshold AND close > open) OR (close > open AND close > previous high AND open < previous low).
Calculation: Bearish reversal candle = (high - low > 0 AND (high - max(open, close)) / (high - low) >= wick-ratio threshold AND close < open) OR (close < open AND close < previous low AND open > previous high).
Calculation: Support touch = a confirmed pivot low exists AND abs(low - latest confirmed pivot low) <= ATR multiplied by a tolerance.
Calculation: Resistance touch = a confirmed pivot high exists AND abs(high - latest confirmed pivot high) <= ATR multiplied by the same tolerance.
Calculation: Bullish count = number of true conditions among bullish divergence, volume climax, bullish reversal candle, and support touch.
Calculation: Bearish count = number of true conditions among bearish divergence, volume climax, bearish reversal candle, and resistance touch.
Calculation: Signal cooldown = current bar index minus the index of the most recent confirmed long or short signal; initialize the last signal index to zero and update it whenever either confirmed signal fires.
Long: Bullish count >= minimum confluences AND bullish count > bearish count.
Short: Bearish count >= minimum confluences AND bearish count > bullish count.
Long: Chart bar is confirmed AND bullish count >= minimum confluences AND bullish count > bearish count AND signal cooldown >= cooldown threshold.
Short: Chart bar is confirmed AND bearish count >= minimum confluences AND bearish count > bullish count AND signal cooldown >= cooldown threshold.