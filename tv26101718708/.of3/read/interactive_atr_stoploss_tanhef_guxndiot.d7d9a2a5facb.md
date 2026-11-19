Calculation: Upper ATR band = upper-band source + ATR(true range, lookback, averaging type) × multiplier
Calculation: Lower ATR band = lower-band source − ATR(true range, lookback, averaging type) × multiplier
Calculation: Long trailing stop = highest lower ATR band since the trail start bar
Calculation: Short trailing stop = lowest upper ATR band since the trail start bar
Calculation: Long profit target = target input in price mode, or start-bar close + target input × (start-bar close − initial long trailing stop) in risk/reward mode
Calculation: Short profit target = target input in price mode, or start-bar close − target input × (initial short trailing stop − start-bar close) in risk/reward mode
Exit: Long, the long trail was active on the preceding bar AND (trigger is Wick AND low < long trailing stop OR trigger is Close AND close[1] < long trailing stop) OR the long trail remains active AND (cross(close, long profit target) OR trigger is Wick AND (cross(high, long profit target) OR cross(low, long profit target)))
Exit: Short, the short trail was active on the preceding bar AND (trigger is Wick AND high > short trailing stop OR trigger is Close AND close[1] > short trailing stop) OR the short trail remains active AND (cross(close, short profit target) OR trigger is Wick AND (cross(high, short profit target) OR cross(low, short profit target)))