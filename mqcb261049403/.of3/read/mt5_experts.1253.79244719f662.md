Calculation: Short smoothed RSI = MovingAverage(RSI(close, indicator lookback), shorter smoothing lookback, smoothing method, phase)
Calculation: Long smoothed RSI = MovingAverage(RSI(close, indicator lookback), longer smoothing lookback, smoothing method, phase)
Calculation: Short smoothed CCI = MovingAverage(CCI(typical price, indicator lookback), shorter smoothing lookback, smoothing method, phase)
Calculation: Long smoothed CCI = MovingAverage(CCI(typical price, indicator lookback), longer smoothing lookback, smoothing method, phase)
Calculation: Bullish state = Short smoothed RSI > Long smoothed RSI AND Short smoothed CCI > Long smoothed CCI
Calculation: Bearish state = Short smoothed RSI < Long smoothed RSI AND Short smoothed CCI < Long smoothed CCI
Calculation: Neutral state = NOT Bullish state AND NOT Bearish state
Long: Bullish state on each T1 bar, including the bar still forming
Short: Bearish state on each T1 bar, including the bar still forming
Long: Bullish state on the last completed T1 bar AND NOT Bullish state on the preceding completed T1 bar
Short: Bearish state on the last completed T1 bar AND NOT Bearish state on the preceding completed T1 bar
Exit: long, Bearish state on the last completed T1 bar AND Bearish state on the preceding completed T1 bar
Exit: short, Bullish state on the last completed T1 bar AND Bullish state on the preceding completed T1 bar
Exit: long, Neutral state on the last completed T1 bar AND configured to exit on any color
Exit: short, Neutral state on the last completed T1 bar AND configured to exit on any color