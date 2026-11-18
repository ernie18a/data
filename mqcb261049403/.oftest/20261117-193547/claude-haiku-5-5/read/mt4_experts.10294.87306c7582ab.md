Calculation: fast EMA = exponential moving average of (high + low) / 2 with fast period, which is shorter than slow period, over signal-timeframe bars up to the forming bar
Calculation: slow EMA = exponential moving average of (high + low) / 2 with slow period over signal-timeframe bars up to the forming bar
Calculation: parabolic SAR = parabolic SAR with SAR step and SAR maximum over signal-timeframe bars, value at the forming bar
Calculation: close EMA at a bar = exponential moving average of close with power period over signal-timeframe bars up to that bar
Calculation: bears power = low of the forming signal-timeframe bar - close EMA at the forming bar
Calculation: previous bears power = low of the last completed signal-timeframe bar - close EMA at that bar
Calculation: bulls power = high of the forming signal-timeframe bar - close EMA at the forming bar
Calculation: previous bulls power = high of the last completed signal-timeframe bar - close EMA at that bar
Calculation: bar hour = hour of the datetime of the current base bar
Long: bar hour > hour start AND bar hour < hour end AND fast EMA > slow EMA AND parabolic SAR < low of current base bar AND bulls power > 0 AND bulls power < previous bulls power
Short: bar hour > hour start AND bar hour < hour end AND fast EMA < slow EMA AND parabolic SAR > high of current base bar AND bears power < 0 AND bears power > previous bears power
Exit: long, low of current base bar <= entry price - long stop distance OR high of current base bar >= entry price + long target distance
Exit: short, high of current base bar >= entry price + short stop distance OR low of current base bar <= entry price - short target distance