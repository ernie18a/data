Calculation: EMA filter = EMA(close, EMA lookback, calculated on T1 bars using the current T1 bar and sampled on chart bars)
Calculation: Stochastic RSI K = SMA(Stochastic RSI(close, RSI lookback, stochastic lookback), K smoothing) on chart bars
Calculation: Stochastic RSI D = SMA(Stochastic RSI K, D smoothing) on chart bars
Calculation: Supertrend 1 = Supertrend(hl2, first ATR lookback parameter, first multiplier parameter, shared ATR method parameter) on chart bars
Calculation: Supertrend 2 = Supertrend(hl2, second ATR lookback parameter, second multiplier parameter, shared ATR method parameter) on chart bars
Calculation: Supertrend 3 = Supertrend(hl2, third ATR lookback parameter, third multiplier parameter, shared ATR method parameter) on chart bars
Calculation: Long stop level = Lowest(low, long stop lookback) on the entry bar
Calculation: Short stop level = Highest(high, short stop lookback) on the entry bar
Long: close > EMA filter AND Stochastic RSI K < oversold threshold AND Stochastic RSI K crosses above Stochastic RSI D AND close is above at least two of Supertrend 1, Supertrend 2, and Supertrend 3 AND datetime is within the configured start and end dates, inclusive AND position is flat AND long entry enable parameter = true
Short: close < EMA filter AND Stochastic RSI K > overbought threshold AND Stochastic RSI K crosses below Stochastic RSI D AND close is below at least two of Supertrend 1, Supertrend 2, and Supertrend 3 AND datetime is within the configured start and end dates, inclusive AND position is flat AND short entry enable parameter = true
Exit: Long, low <= Long stop level OR high >= entry price + (entry price - Long stop level) * long profit factor
Exit: Short, high >= Short stop level OR low <= entry price - (Short stop level - entry price) * short profit factor