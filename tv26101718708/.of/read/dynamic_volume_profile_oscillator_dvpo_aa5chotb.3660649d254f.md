Calculation: VWMean = sum(close*volume)/sum(volume) over a lookback window of N bars including the current bar
Calculation: VWDev = sum(|close - VWMean| * volume/sum(volume)) over the same window
Calculation: Osc = EMA(50 + 25*(close - VWMean)/VWDev, smoothing length); raw value is 50 if VWDev = 0
Calculation: Mid = SMA(Osc, M); Band = Z * stdev(Osc, M) using the same M; Upper = Mid + Band; Lower = Mid - Band
Calculation: Fast = EMA(Osc, short length); Slow = EMA(Osc, longer length than Fast)
Long: Osc crosses above Upper (previous Osc <= previous Upper AND current Osc > current Upper)
Short: Osc crosses below Lower (previous Osc >= previous Lower AND current Osc < current Lower)
Long: Fast crosses above Slow (previous Fast <= previous Slow AND current Fast > current Slow)
Short: Fast crosses below Slow (previous Fast >= previous Slow AND current Fast < current Slow)
Long: Osc > Mid OR Fast > Slow (bullish state)
Short: Osc <= Mid AND Fast <= Slow (bearish state)