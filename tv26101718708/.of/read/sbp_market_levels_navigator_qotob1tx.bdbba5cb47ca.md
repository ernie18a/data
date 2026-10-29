Calculation: ATR = average true range over a lookback
Calculation: Touch distance = ATR × a threshold
Calculation: Break distance = ATR × a threshold
Calculation: Active levels = unexpired confirmed swing highs (resistance) and swing lows (support), plus enabled prior-period highs/lows and daily classic pivot, S1, S2, R1, and R2 levels; prior-period references use the last completed higher-timeframe bar
Calculation: Daily classic pivot = (prior completed daily high + low + close) / 3; R1 = 2 × pivot − low; S1 = 2 × pivot − high; R2 = pivot + high − low; S2 = pivot − high + low
Calculation: Support test = at least one active support level has a counted touch, where high ≥ level − touch distance and low ≤ level + touch distance, with the minimum bar gap since its previous counted touch
Calculation: Resistance test = same touch condition for at least one active resistance level
Calculation: Bullish rejection = at least one active support level has low ≤ level + touch distance, close > level, lower wick / max(high − low, minimum tick) ≥ a threshold, and (close − low) / max(high − low, minimum tick) ≥ a threshold
Calculation: Bearish rejection = at least one active resistance level has high ≥ level − touch distance, close < level, upper wick / max(high − low, minimum tick) ≥ a threshold, and (high − close) / max(high − low, minimum tick) ≥ a threshold
Calculation: Bullish role change = an active resistance level has consecutive closes above level + break distance; the count resets when this condition fails, and the level then becomes support
Calculation: Bearish role change = an active support level has consecutive closes below level − break distance; the count resets when this condition fails, and the level then becomes resistance
Calculation: Bullish evidence count = 1 if Support test AND Bullish rejection, otherwise 0, plus 1 if Bullish role change occurs, otherwise 0
Calculation: Bearish evidence count = 1 if Resistance test AND Bearish rejection, otherwise 0, plus 1 if Bearish role change occurs, otherwise 0
Long: bar is confirmed AND Bullish evidence count > 0 AND Bullish evidence count > Bearish evidence count AND previous emitted signal state is not long
Short: bar is confirmed AND Bearish evidence count > 0 AND Bearish evidence count > Bullish evidence count AND previous emitted signal state is not short