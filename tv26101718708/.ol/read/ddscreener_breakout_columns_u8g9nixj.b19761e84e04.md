Calculation: Bullish cloud = close is above both the longer-term EMA pair’s upper edge and the shorter-term EMA pair’s upper edge
Calculation: Bearish cloud = close is below both the longer-term EMA pair’s lower edge and the shorter-term EMA pair’s lower edge
Calculation: Volume spike = current volume is at least a configurable multiple of its moving average
Calculation: Prior-day high/low = high/low of the last completed higher-timeframe daily bar
Calculation: Pivot resistance/support = most recent confirmed pivot high/low in a bounded lookback of higher-timeframe bars, confirmed by configurable left and right bars; use the latest available level (last completed bar historically, possibly forming bar in real time)
Calculation: Resistance break = current close is above the pivot resistance and previous close was at or below the prior resistance value
Calculation: Support break = current close is below the pivot support and previous close was at or above the prior support value
Calculation: Bullish points = 1 for bullish cloud + 1 for close above prior-day high + 1 if either higher-timeframe resistance breaks
Calculation: Bearish points = 1 for bearish cloud + 1 for close below prior-day low + 1 if either higher-timeframe support breaks
Long: Bullish points > bearish points OR (higher-timeframe resistance breaks AND volume spike AND bullish cloud)
Short: Bearish points > bullish points OR (higher-timeframe support breaks AND volume spike AND bearish cloud)