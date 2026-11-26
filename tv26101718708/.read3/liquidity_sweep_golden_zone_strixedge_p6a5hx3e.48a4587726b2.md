Calculation: Active swing low = latest confirmed Pivot Low(low, pivot lookback, pivot lookback), replaced by low after each bar where low < active swing low AND close > active swing low
Calculation: Active swing high = latest confirmed Pivot High(high, pivot lookback, pivot lookback), replaced by high after each bar where high > active swing high AND close < active swing high
Calculation: Golden Zone lower = Lowest(low, lookback) + (Highest(high, lookback) - Lowest(low, lookback)) * lower retracement fraction
Calculation: Golden Zone upper = Lowest(low, lookback) + (Highest(high, lookback) - Lowest(low, lookback)) * upper retracement fraction
Calculation: Golden Zone position = above if close > Golden Zone upper, inside if close >= Golden Zone lower, below otherwise
Calculation: Active swing midpoint = (active swing high + active swing low) / 2 when both are defined
Calculation: Support/resistance position = bullish if close > active swing midpoint, bearish if close < active swing midpoint, neutral otherwise or if the midpoint is undefined
Calculation: EMA bias = bullish if EMA(close, shorter lookback) > EMA(close, longer lookback), bearish if lower, neutral if equal
Calculation: Recent sweep direction = bullish on a bullish sweep, otherwise bearish on a bearish sweep; retain the latest direction through the sweep memory and then set to neutral
Calculation: Bullish score(T) = count of RSI(close, RSI lookback) > RSI midpoint, Golden Zone position(T) is inside or above, support/resistance position(T) is bullish, and EMA bias(T) is bullish; calculated on T bars
Calculation: Bearish score(T) = count of RSI(close, RSI lookback) < RSI midpoint, Golden Zone position(T) is below, support/resistance position(T) is bearish, and EMA bias(T) is bearish; calculated on T bars
Calculation: Confluence score = across T1, T2, T3, and T4, count bullish recent sweep directions, Golden Zone positions inside or above, bullish support/resistance positions, and bullish EMA biases, minus the corresponding bearish counts; calculations run on each T bar and their security values are sampled on chart bars, using the last completed T bar historically and the current/forming T bar in realtime
Long: active swing low is defined AND low < active swing low AND close > active swing low
Short: active swing high is defined AND high > active swing high AND close < active swing high
Long: low < active swing low AND close > active swing low AND close >= Golden Zone lower AND close <= Golden Zone upper
Short: high > active swing high AND close < active swing high AND close >= Golden Zone lower AND close <= Golden Zone upper
Long: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, recent sweep direction is bullish
Short: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, recent sweep direction is bearish
Long: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, Golden Zone position is above
Short: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, Golden Zone position is below
Long: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, support/resistance position is bullish
Short: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, support/resistance position is bearish
Long: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, EMA bias is bullish
Short: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, EMA bias is bearish
Long: on chart bars using T1, T2, T3, or T4 security values, with RSI calculated on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, RSI(close, RSI lookback) >= RSI midpoint AND RSI(close, RSI lookback) <= upper RSI zone threshold
Short: on chart bars using T1, T2, T3, or T4 security values, with RSI calculated on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, RSI(close, RSI lookback) >= lower RSI zone threshold AND RSI(close, RSI lookback) < RSI midpoint
Long: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, bullish score(T) >= minimum aligned conditions
Short: on chart bars using T1, T2, T3, or T4 security values, with calculations on each T's bars and values from the last completed T bar historically and the current/forming T bar in realtime, bearish score(T) >= minimum aligned conditions
Long: confluence score >= confluence threshold
Short: confluence score <= -confluence threshold