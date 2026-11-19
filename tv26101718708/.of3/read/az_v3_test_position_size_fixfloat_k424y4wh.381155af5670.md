Calculation: Smoothed source = EMA(source, smoothing lookback)
Calculation: Fast average = EMA(smoothed source, shorter lookback) on chart bars; in fixed-timeframe mode, EMA of the T1 EMA(source, shorter lookback) values sampled on chart bars, using the T1 bar still forming and the smoothing lookback on chart bars
Calculation: Slow average = EMA(smoothed source, longer lookback) on chart bars; in fixed-timeframe mode, EMA of the T1 EMA(source, longer lookback) values sampled on chart bars, using the T1 bar still forming and the smoothing lookback on chart bars
Calculation: Green bar = fast average > slow average AND smoothed source > fast average
Calculation: Red bar = fast average < slow average AND smoothed source < fast average
Calculation: First green bar = green bar AND NOT green bar[1]
Calculation: First red bar = red bar AND NOT red bar[1]
Calculation: Bullish signal state = bars since first green bar < bars since first red bar
Calculation: Bearish signal state = bars since first red bar < bars since first green bar
Calculation: StochRSI K = SMA(Stochastic(RSI(close, RSI lookback), RSI(close, RSI lookback), RSI(close, RSI lookback), stochastic lookback), K smoothing)
Calculation: StochRSI D = SMA(StochRSI K, D smoothing)
Calculation: Long momentum score = higher score when bullish signal state AND StochRSI D < oversold level AND StochRSI K crosses above StochRSI D; lower score when bullish signal state AND StochRSI D > oversold level AND StochRSI K crosses above StochRSI D; otherwise no signal
Calculation: Short momentum score = higher score when bearish signal state AND StochRSI D > overbought level AND StochRSI K crosses below StochRSI D; lower score when bearish signal state AND StochRSI D < overbought level AND StochRSI K crosses below StochRSI D; otherwise no signal
Long: fast average > slow average AND smoothed source > fast average
Long: fast average < slow average AND smoothed source > fast average AND smoothed source > slow average
Long: fast average < slow average AND smoothed source > fast average AND smoothed source < slow average
Long: bullish signal state
Long: bearish signal state[1] AND first green bar
Long: long momentum score > signal threshold
Long: green bar AND long strategy enabled AND position is flat AND (date filter disabled OR datetime is inside the configured date range)
Short: fast average < slow average AND smoothed source < fast average
Short: fast average > slow average AND smoothed source < fast average AND smoothed source < slow average
Short: fast average > slow average AND smoothed source < fast average AND smoothed source > slow average
Short: bearish signal state
Short: bullish signal state[1] AND first red bar
Short: short momentum score > signal threshold
Exit: Long, low < the lowest low over the stop lookback bars preceding the entry bar OR low <= entry price × (1 − loss threshold)