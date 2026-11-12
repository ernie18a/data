Calculation: EMA fast, EMA mid, EMA slow = EMAs of close with fast length < mid length < slow length
Calculation: macro SMA = SMA of close with lookback longer than the slow EMA
Calculation: Stage2 = macro SMA > macro SMA a few bars ago AND close > macro SMA; Stage4 = macro SMA < macro SMA a few bars ago AND close < macro SMA
Calculation: volume ratio = volume / SMA of volume (1 if volume is missing or zero)
Calculation: panic ratio = max(0, 50 - RSI) / 10 * volume ratio; fomo ratio = max(0, RSI - 50) / 10 * volume ratio (both 0 if volume is missing or zero)
Calculation: momentum = 100 + ((close - lowest low of recent short window) / (highest high of same window - lowest low of same window) - 0.5) * 4 (100 if window range is 0)
Long: panic ratio > panic threshold AND close < open
Long: RSI crosses above the oversold level (below 50) on this bar AND EMA mid > EMA slow AND NOT (panic ratio > panic threshold AND close < open)
Long: EMA fast > EMA mid AND EMA mid > EMA slow on this bar AND NOT (the same stack on the previous bar)
Long: Stage2 true on this bar AND Stage2 false on the previous bar
Long: momentum < oversold momentum level (below 100)
Short: fomo ratio > panic threshold AND close > open AND abs(close - EMA fast) > ATR
Short: EMA fast < EMA mid AND EMA mid < EMA slow on this bar AND NOT (the same stack on the previous bar)
Short: Stage4 true on this bar AND Stage4 false on the previous bar
Short: momentum > overbought momentum level (above 100)