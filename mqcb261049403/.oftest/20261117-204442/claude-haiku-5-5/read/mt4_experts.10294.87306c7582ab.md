Calculation: fast EMA = exponential moving average of (high + low) / 2 over fast period on timeframe T; fast period shorter than slow period
Calculation: slow EMA = exponential moving average of (high + low) / 2 over slow period on timeframe T
Calculation: parabolic SAR = parabolic stop-and-reverse with acceleration step and maximum acceleration on timeframe T
Calculation: bulls power = high minus exponential moving average of close over power period on timeframe T
Calculation: bears power = low minus exponential moving average of close over power period on timeframe T
Long: hour of datetime of forming bar 0 > session start hour AND hour of datetime of forming bar 0 < session end hour AND fast EMA at forming bar 0 > slow EMA at forming bar 0 AND parabolic SAR at forming bar 0 < low of forming bar 0 AND bulls power at forming bar 0 > 0 AND bulls power at forming bar 0 < bulls power at completed bar 1
Short: hour of datetime of forming bar 0 > session start hour AND hour of datetime of forming bar 0 < session end hour AND fast EMA at forming bar 0 < slow EMA at forming bar 0 AND parabolic SAR at forming bar 0 > high of forming bar 0 AND bears power at forming bar 0 < 0 AND bears power at forming bar 0 > bears power at completed bar 1
Exit: long, low of forming bar 0 <= entry price - long stop distance
Exit: long, high of forming bar 0 >= entry price + long target distance
Exit: short, high of forming bar 0 >= entry price + short stop distance
Exit: short, low of forming bar 0 <= entry price - short target distance