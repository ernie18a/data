Calculation: MACD = EMA of close with a shorter length minus EMA of close with a longer length; signal = EMA of MACD; histogram = MACD minus signal.
Calculation: Higher-timeframe MACD and histogram = MACD and histogram calculated separately on each of four higher timeframes, using each still-forming higher-timeframe bar.
Calculation: Bullish alignment = all four higher-timeframe MACDs > 0 AND at least all but one of their histograms > 0.
Calculation: Bearish alignment = all four higher-timeframe MACDs <= 0 AND at most one of their histograms > 0.
Calculation: Coil = absolute histogram <= the linearly interpolated percentile of absolute histogram over a rolling history including the current bar, provided a minimum number of observations is available.
Calculation: Cooldown = bars elapsed since the most recent zero-line cross signal, signal-line cross signal, divergence, or coil release >= cooldown length; all signals on the current bar use the cooldown state before that bar updates it.
Calculation: Histogram pivot = a histogram high or low confirmed after an equal lookback and lookforward length; compare each confirmed pivot with the immediately preceding confirmed pivot of the same type, using the price high or low at each histogram pivot bar.
Long: MACD >= 0.
Short: MACD < 0.
Long: Any higher-timeframe MACD > 0.
Short: Any higher-timeframe MACD <= 0.
Long: Bullish alignment is true AND bullish alignment on the previous chart bar is false.
Short: Bearish alignment is true AND bearish alignment on the previous chart bar is false.
Long: Cooldown is true AND MACD crosses above zero.
Short: Cooldown is true AND MACD crosses below zero.
Long: Cooldown is true AND MACD crosses above signal AND MACD < 0.
Short: Cooldown is true AND MACD crosses below signal AND MACD > 0.
Long: A histogram pivot low is confirmed AND its price low < the preceding histogram pivot low's price low AND its histogram > the preceding histogram pivot low's histogram AND its histogram < 0.
Short: A histogram pivot high is confirmed AND its price high > the preceding histogram pivot high's price high AND its histogram < the preceding histogram pivot high's histogram AND its histogram > 0.
Long: Coil is false AND coil was true on the previous bar for at least the minimum consecutive coil duration AND histogram > 0.
Short: Coil is false AND coil was true on the previous bar for at least the minimum consecutive coil duration AND histogram < 0.