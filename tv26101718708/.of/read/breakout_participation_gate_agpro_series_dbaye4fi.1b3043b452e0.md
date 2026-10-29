Calculation: Upper gate = highest high over the lookback, excluding the current bar
Calculation: Lower gate = lowest low over the lookback, excluding the current bar
Calculation: Relative volume = current volume / simple moving average of volume
Calculation: Breakout quality = clamp(0.32 × clamp(relative volume / minimum relative volume × 100, 0, 150) + 0.27 × clamp(body percentage / minimum body percentage × 100, 0, 140) + 0.18 × breakout-direction close location percentage + 0.13 × clamp(bar range / ATR × 55, 0, 120) + 0.10 × (100 if close agrees with the EMA trend, otherwise 35), 0, 100); for upside breaks, close location is (close − low) / bar range × 100; for downside breaks it is 100 minus that value
Long: close > upper gate + ATR × breakout buffer
Long: during the retest window after an upside break, current bar touches the gate shelf and close > gate and close > open
Long: during the retest window after an upside break, close > gate + ATR × expansion distance and relative volume ≥ 0.85 × minimum relative volume
Short: close < lower gate − ATR × breakout buffer
Short: during the retest window after a downside break, current bar touches the gate shelf and close < gate and close < open
Short: during the retest window after a downside break, close < gate − ATR × expansion distance and relative volume ≥ 0.85 × minimum relative volume
Exit: long, during the retest window after an upside break and close < gate − ATR × fakeout distance
Exit: short, during the retest window after a downside break and close > gate + ATR × fakeout distance