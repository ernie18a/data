Calculation: Bull dominance(T) = if SUM(ABS(close - open), lookback) = 0 then neutral-dominance parameter, otherwise 100 × SUM(MAX(close - open, 0), lookback) / SUM(ABS(close - open), lookback)
Calculation: Bear dominance(T) = if SUM(ABS(close - open), lookback) = 0 then neutral-dominance parameter, otherwise 100 × SUM(MAX(open - close, 0), lookback) / SUM(ABS(close - open), lookback)
Calculation: Bull probability(T) = body-weight parameter × Bull dominance(T) + trend-bonus parameter when close > SMA(close, lookback, T), otherwise body-weight parameter × Bull dominance(T); calculate on T bars, where T is chart bars or T1/T2/T3; on chart bars, T1/T2/T3 use the still-forming bar in realtime and the last completed bar on historical bars until T closes
Calculation: Bear probability(T) = body-weight parameter × Bear dominance(T) + trend-bonus parameter when close < SMA(close, lookback, T), otherwise body-weight parameter × Bear dominance(T)
Calculation: Bullish bias = when multi-timeframe agreement is disabled, Bull probability(chart bars) > minimum-score parameter; when enabled, at least the agreement-count parameter of Bull probability(chart bars), Bull probability(T1), Bull probability(T2), and Bull probability(T3) exceed the minimum-score parameter
Calculation: Bearish bias = when multi-timeframe agreement is disabled, Bull probability(chart bars) <= minimum-score parameter AND Bear probability(chart bars) > minimum-score parameter; when enabled, at least the agreement-count parameter of those four timeframes have Bull probability <= the minimum-score parameter AND Bear probability > the minimum-score parameter
Calculation: Entry price = close on the signal bar
Calculation: Long stop = Lowest(low, swing-lookback parameter) on the signal bar × (1 - stop-buffer parameter / 100)
Calculation: Long target = entry price + (entry price - Long stop) × reward-to-risk parameter
Calculation: Short stop = Highest(high, swing-lookback parameter) on the signal bar × (1 + stop-buffer parameter / 100)
Calculation: Short target = entry price - (Short stop - entry price) × reward-to-risk parameter
Long: confirmed chart bar AND position is flat at the start of the bar AND previous chart bar's bias was not bullish AND Bullish bias
Short: confirmed chart bar AND position is flat at the start of the bar AND previous chart bar's bias was not bearish AND Bearish bias
Exit: long, high >= Long target OR low <= Long stop
Exit: short, low <= Short target OR high >= Short stop