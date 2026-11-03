Calculation: Support = lowest low over the lookback period, including the current bar
Calculation: Resistance = highest high over the lookback period, including the current bar
Calculation: ATR = average true range over its configured period
Calculation: Volume average = simple moving average of volume over the ATR period
Calculation: Trend average = configured EMA or SMA of close
Calculation: Long target 1 = support + ATR × reward-to-risk ratio × target-1 multiplier
Calculation: Long target 2 = support + ATR × reward-to-risk ratio × target-2 multiplier
Calculation: Short target 1 = resistance − ATR × reward-to-risk ratio × target-1 multiplier
Calculation: Short target 2 = resistance − ATR × reward-to-risk ratio × target-2 multiplier
Calculation: Eligible time = time filter disabled, or current UTC hour is within the configured timezone-adjusted start/end hours (inclusive, including overnight windows), day-of-week settings pass, and—if lunch avoidance is enabled—current time is outside 12:00–13:00 in the selected timezone
Long: close > support − 0.5 × ATR AND low ≤ support AND volume > volume average AND (trend filter disabled OR close > trend average) AND eligible time
Short: close < resistance + 0.5 × ATR AND high ≥ resistance AND volume > volume average AND (trend filter disabled OR close < trend average) AND eligible time
Exit: long, low ≤ support − ATR × stop-loss multiplier when trailing is disabled or inactive; otherwise low ≤ long trailing stop, which activates when (close − entry price) / ATR ≥ configured activation multiplier and is initialized to close − ATR × configured trail-distance multiplier, then updated to the greater of its prior value and close − ATR × configured trail-distance multiplier; high ≥ long target 1 when partial closes are disabled or target 1 has not yet been reached and the configured partial quantity can be closed; high ≥ long target 2 after target 1 when partial closes are enabled
Exit: short, high ≥ resistance + ATR × stop-loss multiplier when trailing is disabled or inactive; otherwise high ≥ short trailing stop, which activates when (entry price − close) / ATR ≥ configured activation multiplier and is initialized to close + ATR × configured trail-distance multiplier, then updated to the lesser of its prior value and close + ATR × configured trail-distance multiplier; low ≤ short target 1 when partial closes are disabled or target 1 has not yet been reached and the configured partial quantity can be closed; low ≤ short target 2 after target 1 when partial closes are enabled