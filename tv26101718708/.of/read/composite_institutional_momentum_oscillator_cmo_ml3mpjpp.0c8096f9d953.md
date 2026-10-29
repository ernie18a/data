Calculation: CMO = on the configured higher-timeframe bar still forming: calculate OHLC4; estimate delta as volume × ((OHLC4 − low) − (high − OHLC4)) / max(high − low, minimum price increment); take its short-lookback SMA; calculate volume efficiency as volume / max(high − low, minimum price increment) and its long-lookback SMA; set weight to max(abs(delta SMA) × volume efficiency / its long-lookback SMA × volume, 1); calculate the long-lookback weighted average of OHLC4 using that weight; calculate a short-lookback WMA and a longer-lookback WMA of OHLC4, form 2 × short WMA − long WMA, smooth it with a WMA of rounded square root of the short lookback; subtract the weighted average, divide by long-lookback standard deviation of OHLC4, then apply a 3-period EMA.
Calculation: Higher-timeframe bullish = higher-timeframe OHLC4 >= higher-timeframe VWMA of OHLC4 weighted by volume over the long lookback, using the still-forming higher-timeframe bar.
Calculation: Bullish sweep = low < the prior bars' long-lookback lowest low AND OHLC4 > that lowest low.
Calculation: Bearish sweep = high > the prior bars' long-lookback highest high AND OHLC4 < that highest high.
Long: CMO > 1 AND higher-timeframe bullish
Long: Bullish sweep AND CMO < 0
Long: CMO crosses above -1 after a prior CMO < -1, before CMO reaches 0.05
Short: CMO < -1 AND NOT higher-timeframe bullish
Short: Bearish sweep AND CMO > 0
Short: CMO <= -0.05