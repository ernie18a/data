Calculation: Compression intensity = 0.4 × (1 − Bollinger Band Width percentile rank / 100) + 0.4 × (1 − ATR percentile rank / 100) + 0.2 × body compression score; the percentile ranks use the same lookback.
Calculation: Body compression score = clamp(1 − (body Z-score + 2) / 4, 0, 1), where body = |close − open| and body Z-score = (body − its moving average) / its standard deviation.
Calculation: Chamber high/low = highest high / lowest low over the chamber initialization lookback on the first active bar, then the running maximum high / minimum low on subsequent active bars; lock these bounds when compression ends.
Calculation: Locked CVD slope = on the first active bar, 0; on each subsequent active bar, the sum of signed volume since the first active bar divided by the number of compression bars. Signed volume is +volume when close > open, −volume when close < open, and 0 otherwise. Retain the last active-bar slope when compression ends.
Calculation: Breakout target price = breakout close + chamber width for a long breakout, or breakout close − chamber width for a short breakout; chamber width = locked chamber high − locked chamber low.
Long: Compression intensity <= activation threshold AND previous-bar compression intensity > activation threshold AND close > locked chamber high AND locked CVD slope > 0
Short: Compression intensity <= activation threshold AND previous-bar compression intensity > activation threshold AND close < locked chamber low AND locked CVD slope < 0
Exit: long, high >= breakout target price
Exit: short, low <= breakout target price