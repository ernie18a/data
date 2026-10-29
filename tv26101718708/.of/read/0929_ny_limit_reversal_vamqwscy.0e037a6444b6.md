Calculation: 09:29 New York close = close of the bar timestamped 09:29 in New York time
Calculation: Long limit = 09:29 New York close - offset
Calculation: Short limit = 09:29 New York close + offset
Calculation: Long stop = Long limit - stop distance
Calculation: Long target = Long limit + (stop distance × reward-to-risk ratio)
Calculation: Short stop = Short limit + stop distance
Calculation: Short target = Short limit - (stop distance × reward-to-risk ratio)
Long: after the 09:29 New York bar and before 09:35 New York time, no order has been submitted that day, position is flat, and low ≤ Long limit
Short: after the 09:29 New York bar and before 09:35 New York time, no order has been submitted that day, position is flat, and high ≥ Short limit
Exit: long, low ≤ Long stop OR high ≥ Long target
Exit: short, high ≥ Short stop OR low ≤ Short target