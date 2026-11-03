Calculation: Fast HA bull = EMA-smoothed Heikin-Ashi close > EMA-smoothed Heikin-Ashi open, using the current bar of a higher timeframe, including while it is forming
Calculation: Major HA bull = EMA-smoothed Heikin-Ashi close > EMA-smoothed Heikin-Ashi open, using the current bar of a higher timeframe, including while it is forming
Calculation: Bull aligned = Fast HA bull AND Major HA bull
Calculation: Bear aligned = NOT Fast HA bull AND NOT Major HA bull
Calculation: Stochastic %K = short-lookback SMA of raw stochastic %K, where raw %K = (close − lowest low) / (highest high − lowest low) × 100 over a longer lookback
Calculation: Stochastic %D = longer-lookback SMA of Stochastic %K
Calculation: Short-lookback EMA = EMA of close with a shorter lookback than the long-lookback EMA
Calculation: Long-lookback EMA = EMA of close with a longer lookback than the short-lookback EMA
Long: Stochastic %K > Stochastic %D AND previous Stochastic %K ≤ previous Stochastic %D AND Stochastic %K < oversold threshold AND Bull aligned OR Short-lookback EMA > Long-lookback EMA AND previous Short-lookback EMA ≤ previous Long-lookback EMA
Short: Stochastic %K < Stochastic %D AND previous Stochastic %K ≥ previous Stochastic %D AND Stochastic %K > overbought threshold AND Bear aligned OR Short-lookback EMA < Long-lookback EMA AND previous Short-lookback EMA ≥ previous Long-lookback EMA