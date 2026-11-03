Calculation: Fast and slow exponential moving averages = exponential moving averages of close over shorter and longer lookbacks, respectively
Calculation: Relative strength index = RSI of close over a lookback
Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Historical rebound target = highest percentage gain from the projection base reached within the rebound window by at least the selected fraction of completed historical dip episodes with similar drawdown depth
Long: fast exponential moving average crosses above slow exponential moving average AND close > slow exponential moving average AND (relative strength index > 50 OR volume > average volume)
Exit: Long, high >= selected historical rebound target price OR rebound window has ended