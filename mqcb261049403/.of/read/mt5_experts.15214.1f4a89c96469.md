Calculation: Smoothed Heiken Ashi state = smooth each bar’s open, high, low, and close using the same smoothing method and lookback; Heiken Ashi close is their average; Heiken Ashi open is the average of the prior bar’s Heiken Ashi open and close. State is bullish when Heiken Ashi close > Heiken Ashi open, otherwise bearish. Use completed bars on the indicator timeframe, which may be higher or lower than the chart timeframe.
Long: prior completed state is bearish AND latest completed state is bullish
Short: prior completed state is bullish AND latest completed state is bearish
Exit: long, latest completed state is bearish
Exit: short, latest completed state is bullish