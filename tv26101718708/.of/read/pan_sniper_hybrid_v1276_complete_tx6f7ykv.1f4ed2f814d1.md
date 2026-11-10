Calculation: Confirmed pivot high/low = a high/low that is the highest/lowest among its specified left and right neighboring chart bars, available when the right-side bars have completed; retain the latest confirmed value, initially unavailable.
Calculation: Bull volume fraction = sum of volume on completed lower-timeframe bars within the chart bar whose close > open, divided by total volume on those lower-timeframe bars; use 0.5 when total volume is zero.
Calculation: Projected high/low = open of the still-forming higher-timeframe bar plus/minus the simple moving average of high minus low over higher-timeframe bars, using the last completed higher-timeframe bar.
Calculation: Bullish fair value gap = low > high two chart bars ago AND previous close > high two chart bars ago.
Calculation: Bearish fair value gap = high < low two chart bars ago AND previous close < low two chart bars ago.
Calculation: Swing high = latest high recorded when high crosses above the highest high of a lookback ending on the previous chart bar; swing low = latest low recorded when low crosses below the lowest low of a lookback ending on the previous chart bar.
Calculation: Bearish order-block top = high two chart bars ago when the previous bar had a bearish fair value gap OR its close crossed below the swing low as it stood one bar before that previous bar; retain the top until high crosses above it, then make it unavailable. Update it before testing the current bar's crossover.
Long: A newly confirmed pivot high > the previous confirmed pivot high, substituting zero if none exists.
Short: A newly confirmed pivot high <= the previous confirmed pivot high, substituting zero if none exists.
Long: A newly confirmed pivot low >= the previous confirmed pivot low, substituting zero if none exists.
Short: A newly confirmed pivot low < the previous confirmed pivot low, substituting zero if none exists.
Long: EMA of close > its previous value.
Short: EMA of close <= its previous value.
Long: Bull volume fraction > the bull threshold.
Short: Bull volume fraction < the bear threshold.
Long: MACD line crosses above its signal line AND close > EMA of close AND bull volume fraction > the bull threshold.
Short: MACD line crosses below its signal line AND close < EMA of close AND bull volume fraction < the bear threshold.
Long: Low < latest confirmed pivot low AND close > latest confirmed pivot low AND bull volume fraction > the bullish sweep threshold.
Short: High > latest confirmed pivot high AND close < latest confirmed pivot high AND bull volume fraction < the bearish sweep threshold.
Long: (Low <= last completed higher-timeframe low + true range multiplied by a zone factor OR low <= projected low) AND ((min(open, close) - low > true range multiplied by a longer-wick factor AND high - max(open, close) < true range multiplied by a shorter-wick factor) OR (close > previous open AND open < previous close AND close - open > true range multiplied by a body factor)) AND volume > SMA of volume multiplied by a volume factor AND bars since the last signal from either this line or its corresponding short line > the shared cooldown; initialize the last signal bar index to zero.
Short: (High >= last completed higher-timeframe high - true range multiplied by a zone factor OR high >= projected high) AND ((high - max(open, close) > true range multiplied by a longer-wick factor AND min(open, close) - low < true range multiplied by a shorter-wick factor) OR (close < previous open AND open > previous close AND open - close > true range multiplied by a body factor)) AND volume > SMA of volume multiplied by a volume factor AND bars since the last signal from either this line or its corresponding long line > the shared cooldown; initialize the last signal bar index to zero.
Long: Bullish fair value gap.
Short: Bearish fair value gap.
Short: Previous bar's close crossed below its preceding bar's swing low OR previous bar had a bearish fair value gap.
Long: (Close crosses above the previous bar's swing high OR close crosses above the latest bearish fair value gap's top, defined as the high-gap bar's low two bars earlier) AND bearish order-block top is available after its current-bar update and invalidation.
Long: Close > EMA of close.
Short: Close <= EMA of close.