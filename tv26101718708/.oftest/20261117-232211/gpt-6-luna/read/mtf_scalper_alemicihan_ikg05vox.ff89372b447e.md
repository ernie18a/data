Calculation: HTF EMA = EMA(close, lookback, Tn, last completed bar), calculated on Tn bars and carried to chart bars
Calculation: Stochastic K = SMA(Stoch(RSI(close, lookback), RSI(close, lookback), RSI(close, lookback), fast lookback), K smoothing)
Calculation: Stochastic D = SMA(Stochastic K, D lookback)
Calculation: ATR = ATR(lookback) on chart bars
Long: position is flat AND chart close > HTF EMA(T1) AND chart close > HTF EMA(T2) AND chart close > HTF EMA(T3) AND Stochastic K crosses above Stochastic D
Short: position is flat AND chart close < HTF EMA(T1) AND chart close < HTF EMA(T2) AND chart close < HTF EMA(T3) AND Stochastic K crosses below Stochastic D
Exit: long, chart low <= entry price - ATR at entry * stop multiplier OR chart high >= entry price + ATR at entry * target multiplier
Exit: short, chart high >= entry price + ATR at entry * stop multiplier OR chart low <= entry price - ATR at entry * target multiplier