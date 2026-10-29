Calculation: Boom Hunter Quotient = For each of two lines, high-pass filter close, apply a SuperSmoother low-pass filter (shorter period for the first line, longer for the second), normalize the filtered value by a peak that decays by a fixed factor and updates to the absolute filtered value when larger, then apply (normalized value + K) / (K × normalized value + 1).
Calculation: Trigger = simple moving average of the first Boom Hunter Quotient.
Calculation: Hull line = selected HMA, EHMA, or THMA of close over length × multiplier; calculated on the chart timeframe, or on a higher timeframe's still-forming bar when higher-timeframe mode is enabled.
Calculation: Volatility threshold = standard deviation of close − open over a lookback on the chart timeframe.
Calculation: Long stop = the lower of entry-signal close − ATR and the lowest low over the lookback ending on the entry-signal bar.
Calculation: Short stop = the higher of entry-signal close + ATR and the highest high over the lookback ending on the entry-signal bar.
Calculation: Long target = entry-signal close + (entry-signal close − long stop) × reward-to-risk factor.
Calculation: Short target = entry-signal close − (short stop − entry-signal close) × reward-to-risk factor.
Long: Trigger crosses above the second Boom Hunter Quotient AND close > Hull line AND Hull line > its value two chart bars ago AND close − open > Volatility threshold AND datetime is within the configured date range AND position size ≤ 0.
Short: Trigger crosses below the second Boom Hunter Quotient AND close < Hull line AND Hull line < its value two chart bars ago AND close − open < −Volatility threshold AND datetime is within the configured date range AND position size ≥ 0.
Exit: Long, low ≤ long stop OR high ≥ long target.
Exit: Short, high ≥ short stop OR low ≤ short target.