Calculation: Undercut(EMA, lookback) = at least one chart-bar low[n] < EMA[n] for n from 0 through lookback − 1
Calculation: EMA reclaim(EMA) = (session filter disabled OR chart bar is within the configured session) AND Undercut(EMA, undercut lookback) AND chart close > EMA
Calculation: Fresh EMA reclaim(EMA) = EMA reclaim(EMA)[1] AND NOT EMA reclaim(EMA)[2]
Long: EMA(close, shorter lookback, T1 bars including the still-forming bar), sampled on chart bars >= EMA(close, longer lookback, T1 bars including the still-forming bar), sampled on chart bars
Short: EMA(close, shorter lookback, T1 bars including the still-forming bar), sampled on chart bars < EMA(close, longer lookback, T1 bars including the still-forming bar), sampled on chart bars
Long: Chart close crosses above EMA(close, shorter lookback, T1 bars including the still-forming bar), sampled on chart bars
Short: Chart close crosses below EMA(close, shorter lookback, T1 bars including the still-forming bar), sampled on chart bars
Long: Chart close crosses above EMA(close, longer lookback, T1 bars including the still-forming bar), sampled on chart bars
Short: Chart close crosses below EMA(close, longer lookback, T1 bars including the still-forming bar), sampled on chart bars
Long: Chart close crosses above EMA(close, separate lookback, T2 bars including the still-forming bar), sampled on chart bars
Short: Chart close crosses below EMA(close, separate lookback, T2 bars including the still-forming bar), sampled on chart bars
Long: EMA(close, shorter lookback, T1 bars including the still-forming bar), sampled on chart bars crosses above EMA(close, longer lookback, T1 bars including the still-forming bar), sampled on chart bars
Short: EMA(close, shorter lookback, T1 bars including the still-forming bar), sampled on chart bars crosses below EMA(close, longer lookback, T1 bars including the still-forming bar), sampled on chart bars
Long: U&R enabled AND, for one of EMA(close, shorter lookback, T1 bars including the still-forming bar), EMA(close, longer lookback, T1 bars including the still-forming bar), or EMA(close, separate lookback, T2 bars including the still-forming bar), sampled on chart bars, Fresh EMA reclaim(EMA) AND (green-confirmation disabled OR chart close > chart open) AND chart close > EMA AND chart close < T1 open of its still-forming bar, sampled on chart bars; no U&R has fired earlier in the current T1 period, and simultaneous signals use priority shorter-lookback T1 EMA, then longer-lookback T1 EMA, then T2 EMA