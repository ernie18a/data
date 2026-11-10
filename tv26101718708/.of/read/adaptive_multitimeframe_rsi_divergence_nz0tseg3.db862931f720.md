Calculation: Composite RSI = EMA on the chart timeframe of the weighted mean of RSI from three higher timeframes, using the same RSI source and period as the chart RSI; on historical bars use the last completed higher-timeframe bars, while on a live bar use the higher-timeframe bars still forming.
Calculation: Confirmed RSI pivot = an RSI high or low whose neighboring RSI values satisfy the pivot test over configurable left and right lookbacks; evaluate the pivot when the right lookback has elapsed.
Calculation: Trend state = retain the previous state until RSI is above composite RSI plus a deadband AND its change from the previous bar is at least a positive slope threshold for every bar in a confirmation window, then set it bullish; or until RSI is below composite RSI minus the deadband AND its change is at most the negative slope threshold for every bar in the window, then set it bearish.
Calculation: Eligible structure pivot = a confirmed RSI pivot whose absolute difference from the preceding confirmed pivot of the same type meets a minimum swing AND whose pivot bar is at least a minimum spacing after the last eligible pivot of that type; update the spacing reference for every eligible pivot.
Long: RSI crosses above composite RSI.
Short: RSI crosses below composite RSI.
Long: Trend state is bullish.
Short: Trend state is bearish.
Long: An eligible RSI high pivot is higher than the preceding confirmed RSI high pivot AND the trend state at the pivot bar is bullish AND the pivot is higher than every previously recorded qualifying high pivot in the current bullish season.
Long: An eligible RSI low pivot is greater than or equal to the preceding confirmed RSI low pivot AND the trend state at the pivot bar is bullish.
Short: An eligible RSI low pivot is lower than the preceding confirmed RSI low pivot AND the trend state at the pivot bar is bearish AND the pivot is lower than every previously recorded qualifying low pivot in the current bearish season.
Short: An eligible RSI high pivot is less than or equal to the preceding confirmed RSI high pivot AND the trend state at the pivot bar is bearish.
Calculation: Season extremes = reset the recorded qualifying high and low pivots after processing pivots confirmed on a trend-state change bar.
Long: A confirmed RSI low pivot is higher than the preceding confirmed RSI low pivot AND the price low at that pivot is lower than the price low at the preceding RSI low pivot.
Long: A confirmed RSI low pivot is lower than the preceding confirmed RSI low pivot AND the price low at that pivot is higher than the price low at the preceding RSI low pivot AND the number of bars between their confirmations is within the configured minimum and maximum lookback range.
Short: A confirmed RSI high pivot is lower than the preceding confirmed RSI high pivot AND the price high at that pivot is higher than the price high at the preceding RSI high pivot.
Short: A confirmed RSI high pivot is higher than the preceding confirmed RSI high pivot AND the price high at that pivot is lower than the price high at the preceding RSI high pivot.