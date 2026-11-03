Calculation: Kaufman’s efficiency ratio = (current close − close N bars ago) / sum of absolute consecutive close changes over the last N bars
Calculation: ATR buffer = ATR × configured multiplier
Calculation: Long trailing stop = higher of the prior long trailing stop and current low − ATR buffer
Calculation: Short trailing stop = lower of the prior short trailing stop and current high + ATR buffer
Long: Kaufman’s efficiency ratio > 0
Short: Kaufman’s efficiency ratio < 0 AND true range > ATR AND volume > volume simple moving average
Exit: Long, low ≤ long trailing stop OR (long entry condition is false AND close ≥ average entry price + next configured profit target × initial ATR buffer; evaluate targets in order)
Exit: Short, high ≥ short trailing stop OR (short entry condition is false AND close ≤ average entry price; evaluate partial profit targets in order)