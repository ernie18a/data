Calculation: Moving average = selected moving-average type and length applied to selected price source, using the last completed chart bar
Calculation: ATR = selected average of true range over the configured length, using the last completed chart bar
Calculation: Upper/lower ATR band = last completed moving average +/− ATR × configured multiplier
Calculation: Confirmed uptrend/downtrend = confirmation price (close, or high for uptrend and low for downtrend) is above the upper band/below the lower band for the configured number of consecutive bars; trend state changes only if it was not already uptrend/downtrend
Calculation: ATR volatility filter = last completed ATR is greater than the configured moving average of current-chart-bar true range
Calculation: Trend MFE/MAE percentages = for each completed confirmed trend, maximum favorable/adverse excursion from the close when that trend began, divided by that starting close and multiplied by 100; long trends use highest high for favorable and lowest low for adverse, short trends use lowest low for favorable and highest high for adverse
Calculation: Automatic target/stop percentages = 70th percentile of the latest up to 500 completed trend MFE/MAE percentages, respectively, with linear interpolation
Long: entry method is Breakout AND confirmed uptrend AND (ATR volatility filter disabled OR ATR volatility filter)
Long: entry method is MA Cross AND trend is up AND current low < moving average AND previous low >= previous moving average AND (ATR volatility filter disabled OR ATR volatility filter)
Short: entry method is Breakout AND confirmed downtrend AND (ATR volatility filter disabled OR ATR volatility filter)
Short: entry method is MA Cross AND trend is down AND current high > moving average AND previous high <= previous moving average AND (ATR volatility filter disabled OR ATR volatility filter)
Exit: long, current high >= entry price × (1 + target percentage/100) OR current low <= entry price × (1 − stop percentage/100)
Exit: short, current low <= entry price × (1 − target percentage/100) OR current high >= entry price × (1 + stop percentage/100)