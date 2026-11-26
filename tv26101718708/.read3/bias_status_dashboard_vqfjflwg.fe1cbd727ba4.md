Calculation: timeframe bias(T) = bullish when at least the minimum component-vote parameter is true and the bullish vote count exceeds the bearish vote count, bearish when at least that minimum is true and the bearish vote count exceeds the bullish vote count, otherwise neutral; bullish votes are EMA(close, fast EMA lookback) > EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) > EMA(close, slow EMA lookback), RSI(close, RSI lookback) > RSI midpoint parameter, and Stoch RSI K(close, Stoch RSI lookback, stochastic lookback, K smoothing) > Stoch RSI D(close, Stoch RSI lookback, stochastic lookback, K smoothing, D smoothing) AND Stoch RSI K > stochastic midpoint parameter; bearish votes use the reverse comparisons; evaluate on T bars and return the current T-bar value to chart bars, including while T is still forming.
Calculation: structure direction = bullish whenever close > latest confirmed pivot high(high, swing lookback, swing lookback), bearish whenever close < latest confirmed pivot low(low, swing lookback, swing lookback), and otherwise retain the prior direction; initially neutral, with bullish taking priority if both comparisons hold.
Calculation: MTF bullish count = number of T1–T8 timeframe biases that are bullish; MTF bearish count = number of T1–T8 timeframe biases that are bearish.
Calculation: MTF bias = bullish when MTF bullish count >= minimum timeframe agreement parameter AND MTF bullish count > MTF bearish count; bearish when MTF bearish count >= minimum timeframe agreement parameter AND MTF bearish count > MTF bullish count; otherwise neutral.
Calculation: bullish score = number of true conditions among structure direction is bullish; EMA(close, fast EMA lookback) > EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) > EMA(close, slow EMA lookback); ADX from DMI(ADX lookback parameter, the same ADX lookback parameter as smoothing) >= minimum ADX parameter AND +DI > -DI; ATR ratio >= ATR expansion ratio parameter OR (ATR ratio < ATR expansion ratio parameter AND ATR ratio > ATR weak ratio parameter); Stoch RSI K(close, Stoch RSI lookback, stochastic lookback, K smoothing) > Stoch RSI D(close, Stoch RSI lookback, stochastic lookback, K smoothing, D smoothing) AND Stoch RSI K > stochastic midpoint parameter; RSI(close, RSI lookback) > RSI midpoint parameter; volume > SMA(volume, volume average lookback); datetime is inside any configured Asia, London, or New York session in the configured timezone; MTF bias is bullish. ATR ratio = ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR average lookback). Bearish score uses the corresponding bearish structure, EMA, DMI, Stoch RSI, RSI, and MTF conditions, with the ATR, volume, and session conditions unchanged; scores are evaluated on chart bars.
Long: timeframe bias(T1) = bullish
Short: timeframe bias(T1) = bearish
Long: timeframe bias(T2) = bullish
Short: timeframe bias(T2) = bearish
Long: timeframe bias(T3) = bullish
Short: timeframe bias(T3) = bearish
Long: timeframe bias(T4) = bullish
Short: timeframe bias(T4) = bearish
Long: timeframe bias(T5) = bullish
Short: timeframe bias(T5) = bearish
Long: timeframe bias(T6) = bullish
Short: timeframe bias(T6) = bearish
Long: timeframe bias(T7) = bullish
Short: timeframe bias(T7) = bearish
Long: timeframe bias(T8) = bullish
Short: timeframe bias(T8) = bearish
Long: EMA(close, fast EMA lookback) > EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) > EMA(close, slow EMA lookback)
Short: EMA(close, fast EMA lookback) < EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) < EMA(close, slow EMA lookback)
Long: Stoch RSI K(close, Stoch RSI lookback, stochastic lookback, K smoothing) > Stoch RSI D(close, Stoch RSI lookback, stochastic lookback, K smoothing, D smoothing) AND Stoch RSI K > stochastic midpoint parameter
Short: Stoch RSI K(close, Stoch RSI lookback, stochastic lookback, K smoothing) < Stoch RSI D(close, Stoch RSI lookback, stochastic lookback, K smoothing, D smoothing) AND Stoch RSI K < stochastic midpoint parameter
Long: RSI(close, RSI lookback) > RSI midpoint parameter
Short: RSI(close, RSI lookback) < RSI midpoint parameter
Long: MTF bias = bullish
Short: MTF bias = bearish
Long: bullish score > bearish score AND max(bullish score, bearish score) >= minimum final score parameter
Short: bearish score > bullish score AND max(bullish score, bearish score) >= minimum final score parameter