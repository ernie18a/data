Calculation: Bar reference = the current chart bar or the still-forming bar of an enabled higher timeframe; the prior bar is the last completed bar of that same timeframe.
Calculation: Inside bar = bar high <= prior high AND bar low >= prior low.
Calculation: Upward directional bar = bar high > prior high AND bar low >= prior low.
Calculation: Downward directional bar = bar low < prior low AND bar high <= prior high.
Calculation: Outside bar = bar high > prior high AND bar low < prior low.
Calculation: Bearish failed breakout = upward directional bar AND, according to the selected detection method, bar close <= bar open OR prior low <= bar close <= prior high OR both conditions OR either condition.
Calculation: Bullish failed breakout = downward directional bar AND, according to the selected detection method, bar close > bar open OR prior low <= bar close <= prior high OR both conditions OR either condition.
Long: Inside bar AND bar close > bar open.
Short: Inside bar AND bar close <= bar open.
Long: Upward directional bar AND bearish failed breakout is not selected or is false.
Short: Downward directional bar AND bullish failed breakout is not selected or is false.
Long: Bullish failed breakout.
Short: Bearish failed breakout.
Long: Outside bar AND bar close > bar open.
Short: Outside bar AND bar close <= bar open.
Long: Chart close > the open of every enabled still-forming higher-timeframe bar and every enabled chart-timeframe bar.
Short: Chart close <= the open of every enabled still-forming higher-timeframe bar and every enabled chart-timeframe bar.