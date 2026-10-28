Calculation: Bullish sweep = low < lowest low over the preceding lookback bars AND close > that lowest low
Calculation: Bearish sweep = high > highest high over the preceding lookback bars AND close < that highest high
Calculation: Volume anomaly = volume > volume average + 2 standard deviations of volume
Calculation: Absorption = absolute(close - open) < 0.4 × (high - low)
Calculation: Aggregated open interest = sum of open interest from three exchanges
Calculation: Long locked stop = break-even after price reaches the first profit-lock threshold; raised to the second threshold when reached
Calculation: Short locked stop = break-even after price reaches the first profit-lock threshold; lowered to the second threshold when reached
Long: bullish sweep occurred within the signal-validity window AND (volume anomaly OR absorption) AND Tether dominance < its moving average AND aggregated open interest <= its moving average
Short: bearish sweep occurred within the signal-validity window AND (volume anomaly OR absorption) AND Tether dominance > its moving average AND aggregated open interest > its moving average
Exit: long, close <= entry price minus the logical stop distance OR low <= catastrophe stop (until a locked stop is set) OR low <= locked stop OR high >= maximum take-profit price OR profit from entry >= dynamic take-profit threshold AND close < 5-period EMA
Exit: short, close >= entry price plus the logical stop distance OR high >= catastrophe stop (until a locked stop is set) OR high >= locked stop OR low <= maximum take-profit price OR profit from entry >= dynamic take-profit threshold AND close > 5-period EMA