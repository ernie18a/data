Calculation: RVOL = volume / SMA(volume, volume length)
Calculation: Bullish zone level = PivotLow(low, pivot left, pivot right)
Calculation: Bullish zone bottom = Bullish zone level - zone ATR width * ATR(high, low, close, ATR length)[pivot right]
Calculation: Bearish zone level = PivotHigh(high, pivot left, pivot right)
Calculation: Bearish zone top = Bearish zone level + zone ATR width * ATR(high, low, close, ATR length)[pivot right]
Long: Bullish zone level is not NA AND RVOL[pivot right] >= minimum RVOL AND ((min(open, close) - low) / (high - low))[pivot right] >= minimum wick AND ((close - low) / (high - low))[pivot right] >= minimum close distance
Short: Bearish zone level is not NA AND RVOL[pivot right] >= minimum RVOL AND ((high - max(open, close)) / (high - low))[pivot right] >= minimum wick AND ((high - close) / (high - low))[pivot right] >= minimum close distance
Long: low <= Bullish zone level AND close > Bullish zone level AND bars since its pivot <= max zone age, on the first bar after formation of the most recent bullish zone where this holds and no close below its bottom occurred from formation through that bar
Short: high >= Bearish zone level AND close < Bearish zone level AND bars since its pivot <= max zone age, on the first bar after formation of the most recent bearish zone where this holds and no close above its top occurred from formation through that bar
Long: close > Bearish zone top AND bars since its pivot <= max zone age, on the first bar from formation of the most recent bearish zone onward where this holds
Short: close < Bullish zone bottom AND bars since its pivot <= max zone age, on the first bar from formation of the most recent bullish zone onward where this holds
Long: low <= Bearish zone top AND close > Bearish zone top AND bars since its pivot <= max zone age, on the first bar after the break bar of the most recent bearish zone where this holds
Short: high >= Bullish zone bottom AND close < Bullish zone bottom AND bars since its pivot <= max zone age, on the first bar after the break bar of the most recent bullish zone where this holds