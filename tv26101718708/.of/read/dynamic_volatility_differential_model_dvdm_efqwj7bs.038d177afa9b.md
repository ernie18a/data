Calculation: Historical volatility = standard deviation of log(close / prior close) over a lookback, multiplied by the annualization factor and 100
Calculation: Volatility spread = implied-volatility index close from the higher-timeframe bar, using the last completed bar, minus historical volatility
Calculation: Upper and lower dynamic thresholds = plus and minus the standard deviation of the volatility spread over the same lookback, multiplied by a multiplier
Long: volatility spread > upper dynamic threshold
Short: volatility spread < lower dynamic threshold
Exit: long, current volatility spread > 0 AND prior volatility spread <= 0
Exit: short, current volatility spread < 0 AND prior volatility spread >= 0