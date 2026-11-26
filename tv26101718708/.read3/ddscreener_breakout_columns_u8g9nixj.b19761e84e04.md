Calculation: previous T1 high = high of the last completed T1 bar, supplied to chart bars
Calculation: previous T1 low = low of the last completed T1 bar, supplied to chart bars
Calculation: cloud bands = the ranges between chart-bar EMA(close, shorter short-cloud lookback) and EMA(close, longer short-cloud lookback), and between EMA(close, shorter long-cloud lookback) and EMA(close, longer long-cloud lookback); each pair’s shorter lookback is less than its longer lookback, and both short-cloud lookbacks are less than both long-cloud lookbacks
Calculation: bullish cloud = chart-bar close is above the top of both cloud bands
Calculation: bearish cloud = chart-bar close is below the bottom of both cloud bands
Calculation: volume spike = (volume / SMA(volume, volume lookback) if the SMA is positive, otherwise the zero-average fallback ratio) >= volume spike threshold
Calculation: T1 resistance = the most recent T1 pivot high found by scanning candidate bars from the T1 right pivot lookback through the T1 pivot lookback plus right pivot lookback; each candidate high is strictly above the highs in the T1 left pivot lookback older bars and right pivot lookback newer bars; calculated on T1 bars and returned to chart bars with lookahead off, using the last completed T1 value historically and the current forming T1 value in real time
Calculation: T1 support = the most recent T1 pivot low found by scanning candidate bars from the T1 right pivot lookback through the T1 pivot lookback plus right pivot lookback; each candidate low is strictly below the lows in the T1 left pivot lookback older bars and right pivot lookback newer bars; calculated on T1 bars and returned to chart bars with lookahead off, using the last completed T1 value historically and the current forming T1 value in real time
Calculation: T2 resistance = the most recent T2 pivot high found by scanning candidate bars from the T2 right pivot lookback through the T2 pivot lookback plus right pivot lookback; each candidate high is strictly above the highs in the T2 left pivot lookback older bars and right pivot lookback newer bars; calculated on T2 bars and returned to chart bars with lookahead off, using the last completed T2 value historically and the current forming T2 value in real time
Calculation: T2 support = the most recent T2 pivot low found by scanning candidate bars from the T2 right pivot lookback through the T2 pivot lookback plus right pivot lookback; each candidate low is strictly below the lows in the T2 left pivot lookback older bars and right pivot lookback newer bars; calculated on T2 bars and returned to chart bars with lookahead off, using the last completed T2 value historically and the current forming T2 value in real time
Calculation: T1 resistance break = T1 resistance exists AND chart-bar close crosses above T1 resistance
Calculation: T1 support break = T1 support exists AND chart-bar close crosses below T1 support
Calculation: T2 resistance break = T2 resistance exists AND chart-bar close crosses above T2 resistance
Calculation: T2 support break = T2 support exists AND chart-bar close crosses below T2 support
Calculation: near level = level exists AND the absolute difference between chart-bar close and level, divided by level and expressed as a percentage, is <= proximity percentage
Calculation: near resistance = near T1 resistance OR near T2 resistance OR near previous T1 high
Calculation: near support = near T1 support OR near T2 support OR near previous T1 low
Calculation: bullish score = equally weighted count of bullish cloud, chart-bar close above previous T1 high, and either T1 resistance break or T2 resistance break
Calculation: bearish score = equally weighted count of bearish cloud, chart-bar close below previous T1 low, and either T1 support break or T2 support break
Long: chart-bar close > previous T1 high
Short: chart-bar close < previous T1 low
Long: bullish cloud
Short: bearish cloud
Long: T1 resistance break
Short: T1 support break
Long: T2 resistance break
Short: T2 support break
Long: bullish score > bearish score
Short: bearish score > bullish score
Long: T1 resistance break AND volume spike AND bullish cloud
Short: T1 support break AND volume spike AND bearish cloud
Long: T2 resistance break AND volume spike AND bullish cloud
Short: T2 support break AND volume spike AND bearish cloud
Long: near resistance AND volume spike AND bullish cloud
Short: near support AND volume spike AND bearish cloud