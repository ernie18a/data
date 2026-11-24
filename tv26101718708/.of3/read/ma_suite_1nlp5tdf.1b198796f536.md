Calculation: First MA = selected MA(source, first lookback, first MA type) on chart timeframe or selected T1/T2; on T1/T2, calculate on that timeframe's bars and use the still-forming bar's value on chart bars
Calculation: Second MA = selected MA(source, second lookback, second MA type) on chart timeframe or selected T1/T2; on T1/T2, calculate on that timeframe's bars and use the still-forming bar's value on chart bars
Calculation: Eighth MA = selected MA(source, eighth lookback, eighth MA type) on chart timeframe or selected T1/T2; on T1/T2, calculate on that timeframe's bars and use the still-forming bar's value on chart bars
Calculation: WaveTrend main and signal = WaveTrend(source, channel lookback, average lookback, signal smoothing)
Long: Eighth MA < Second MA
Short: Eighth MA >= Second MA
Long: Second MA crosses above Eighth MA
Short: Eighth MA crosses above Second MA
Short: First MA crosses below Second MA
Long: Second MA crosses above selected MA(source, third lookback, third MA type) on chart timeframe or selected T1/T2; on T1/T2, calculate on that timeframe's bars and use the still-forming bar's value on chart bars
Short: WaveTrend main crosses below WaveTrend signal
Long: open > Second MA AND open > Eighth MA AND close[1] > open[1] AND close > open AND NOT (WaveTrend main crosses below WaveTrend signal) AND NOT (First MA crosses below Second MA)
Long: WaveTrend main crosses below WaveTrend signal AND WaveTrend signal < WT upper threshold AND WaveTrend signal > WT lower threshold AND RSI(RSI source, RSI lookback) < RSI upper threshold AND RSI(RSI source, RSI lookback) > RSI lower threshold AND SMA(((close - open) / (high - low)) * area multiplier, RSI+MFI lookback) < RSI+MFI threshold