Calculation: Trend(symbol, T) = 1 when close > EMA(close, shorter lookback) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND RSI(close, RSI lookback) > RSI threshold; -1 when close < EMA(close, shorter lookback) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND RSI(close, RSI lookback) < RSI threshold; otherwise 0. For requested timeframes, calculate on T bars and map values to chart bars, using the last completed T bar historically and the still-forming T bar in real time.
Calculation: Symbol score = sum of Trend(symbol, T1), Trend(symbol, T2), Trend(symbol, T3), and Trend(symbol, T4), treating unavailable values as 0.
Calculation: Market total = sum of Symbol score over enabled symbols.
Calculation: Market maximum score = number of enabled symbols multiplied by the number of configured timeframes.
Long: For each enabled symbol and each of T1, T2, T3, and T4, Trend(symbol, T) = 1; OR Trend(chart symbol, chart timeframe) = 1.
Short: For each enabled symbol and each of T1, T2, T3, and T4, Trend(symbol, T) = -1; OR Trend(chart symbol, chart timeframe) = -1.
Long: For each enabled symbol, close on T4 >= close on the prior T4 bar.
Short: For each enabled symbol, close on T4 < close on the prior T4 bar.
Long: For each enabled symbol, Symbol score >= minimum directional score.
Short: For each enabled symbol, Symbol score <= -minimum directional score.
Long: For an enabled symbol, Symbol score equals the number of configured timeframes AND Symbol score != its value on the prior chart bar AND the chart bar is confirmed.
Short: For an enabled symbol, Symbol score equals the negative number of configured timeframes AND Symbol score != its value on the prior chart bar AND the chart bar is confirmed.
Long: Market maximum score > 0 AND Market total >= Market maximum score multiplied by market bias fraction.
Short: Market maximum score > 0 AND Market total <= -Market maximum score multiplied by market bias fraction.