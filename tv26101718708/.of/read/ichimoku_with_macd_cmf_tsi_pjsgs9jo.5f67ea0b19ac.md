Calculation: Ichimoku midpoint = (highest high + lowest low) / 2 over its lookback.
Calculation: Leading Span A = average of the Ichimoku midpoints using the Tenkan and Kijun lookbacks.
Calculation: Leading Span B = Ichimoku midpoint using its own lookback.
Calculation: Current cloud top/bottom = maximum/minimum of Leading Spans A and B from the configured span offset ago.
Calculation: MACD histogram = fast moving average of the source minus the slow moving average, minus the signal moving average of that difference; the fast lookback is shorter than the slow lookback, and each moving average uses its configured simple or exponential type.
Calculation: Chaikin Money Flow = sum(volume × close-location value) / sum(volume) over its lookback, where close-location value = (2 × close − high − low) / (high − low), or zero when high equals low.
Calculation: True Strength Index = 100 × double-smoothed close change / double-smoothed absolute close change; each double smoothing applies two EMAs in sequence, using the configured long and short lookbacks.
Long: Tenkan midpoint > Kijun midpoint AND close > close from the configured Chikou offset ago AND close > current cloud top AND MACD histogram > 0 AND Chaikin Money Flow > 0.1 AND True Strength Index > 0
Short: Tenkan midpoint < Kijun midpoint AND close < close from the configured Chikou offset ago AND close < current cloud bottom AND MACD histogram < 0 AND Chaikin Money Flow < -0.1 AND True Strength Index < 0
Exit: Long, Tenkan midpoint < Kijun midpoint AND close < close from the configured Chikou offset ago AND close < current cloud bottom AND MACD histogram < 0 AND Chaikin Money Flow < -0.1 AND True Strength Index < 0
Exit: Short, Tenkan midpoint > Kijun midpoint AND close > close from the configured Chikou offset ago AND close > current cloud top AND MACD histogram > 0 AND Chaikin Money Flow > 0.1 AND True Strength Index > 0