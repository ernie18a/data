Calculation: T2 expansion = at least minimum-expansion-count of the latest expansion-window completed T2 bars have abs(close - open) >= expansion-multiplier × ATR(ATR-lookback, T2, last completed bar), and the last completed T2 bar has (high - low - abs(close - open)) / (high - low) <= 1 - max-wick-ratio; evaluated on chart bars using T2 values
Calculation: Selected FVG = retain the candidate Fair Value Gap whose midpoint is strictly nearer to chart close than the selected gap's midpoint, testing bullish before bearish; a bullish candidate spans the current, still-forming T1 bar's high to the oldest bar's low when the oldest bar's low > the current bar's high, and a bearish candidate spans the oldest bar's high to the current bar's low when the oldest bar's high < the current bar's low; evaluate on chart bars using T1 values
Calculation: Asia reversal = (completed Asia-session high > last completed T3 high AND Asia-session close < last completed T3 high) OR (completed Asia-session low < last completed T3 low AND Asia-session close > last completed T3 low); use session values from chart bars and T3 values from the last completed bar
Calculation: London bullish reversal = completed London-session low < Asia-session low AND London-session close > Asia-session low
Calculation: London bearish reversal = completed London-session high > Asia-session high AND London-session close < Asia-session high
Long: T2 expansion AND last completed T2 close > open
Short: T2 expansion AND last completed T2 close < open
Long: Selected FVG is bullish
Short: Selected FVG is bearish
Long: close > open of the chart bar at midnight in the configured session timezone
Short: close < open of the chart bar at midnight in the configured session timezone
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) on chart bars
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) on chart bars
Long: London bullish reversal OR (NOT London bullish reversal AND NOT London bearish reversal AND Asia reversal AND last completed T2 close > open)
Short: (London bearish reversal AND NOT London bullish reversal) OR (NOT London bullish reversal AND NOT London bearish reversal AND Asia reversal AND last completed T2 close < open)