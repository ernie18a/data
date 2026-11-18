Calculation: Stochastic %K = SMA(Stochastic(close, high, low, stochastic lookback), stochastic smoothing)
Calculation: Stochastic %D = SMA(Stochastic %K, stochastic smoothing)
Calculation: Short EMA = EMA(close, shorter lookback)
Calculation: Long EMA = EMA(close, longer lookback)
Calculation: Fast HA bullish = EMA(Heikin-Ashi close from the T1 bar still forming, fast HA smoothing, evaluated on chart bars taking T1 values) > EMA(Heikin-Ashi open from the T1 bar still forming, fast HA smoothing, evaluated on chart bars taking T1 values)
Calculation: Major HA bullish = EMA(Heikin-Ashi close from the T2 bar still forming, major HA smoothing, evaluated on chart bars taking T2 values) > EMA(Heikin-Ashi open from the T2 bar still forming, major HA smoothing, evaluated on chart bars taking T2 values)
Long: Stochastic %K crosses above Stochastic %D AND Stochastic %K < lower stochastic threshold AND Fast HA bullish AND Major HA bullish
Long: Stochastic %K crosses above Stochastic %D AND Stochastic %K < lower stochastic threshold AND Fast HA bullish AND Major HA bullish AND close > Short EMA
Long: Short EMA crosses above Long EMA
Short: Stochastic %K crosses below Stochastic %D AND Stochastic %K > upper stochastic threshold AND NOT Fast HA bullish AND NOT Major HA bullish
Short: Stochastic %K crosses below Stochastic %D AND Stochastic %K > upper stochastic threshold AND NOT Fast HA bullish AND NOT Major HA bullish AND close < Short EMA
Short: Short EMA crosses below Long EMA