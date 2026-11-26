Calculation: Hull = selected HMA, EHMA, or THMA(source, lookback), calculated on chart bars, or on T1 bars and carried onto chart bars when MTF is enabled (uses the forming T1 bar in real time and the latest completed T1 bar historically)
Calculation: Volatility expansion = (SMA(close, lookback) - BB multiplier × StdDev(close, lookback) < SMA(close, lookback) - KC multiplier × SMA(True Range, lookback)) AND (SMA(close, lookback) + BB multiplier × StdDev(close, lookback) > SMA(close, lookback) + KC multiplier × SMA(True Range, lookback))
Long: Hull crosses above its value on the previous chart bar
Long: Hull crosses above its value on the previous chart bar AND Volatility expansion
Short: Hull crosses below its value on the previous chart bar
Short: Hull crosses below its value on the previous chart bar AND Volatility expansion