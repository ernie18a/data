Calculation: Money Flow Z-Score = (CMF(money-flow lookback) - SMA(CMF(money-flow lookback), normalization lookback)) / STDEV(CMF(money-flow lookback), normalization lookback), or 0 when the standard deviation is 0
Calculation: Pressure state = initialize to Neutral; retain the prior state when the Z-score is missing; set Neutral when the Z-score is 0; for a positive Z-score, from Extreme Buying remain there until the Z-score is below outer sigma minus hysteresis, then set Elevated Buying if the Z-score is at least inner sigma, otherwise Neutral; from Elevated Buying set Extreme Buying if the Z-score is at least outer sigma, Neutral if it is below inner sigma minus hysteresis, otherwise remain Elevated Buying; from any other state set Extreme Buying if the Z-score is at least outer sigma, else Elevated Buying if it is at least inner sigma, else Neutral; for a negative Z-score apply the same transitions to its absolute value with Selling states
Long: Money Flow Z-Score > 0
Short: Money Flow Z-Score < 0
Long: pressure state is Elevated Buying or Extreme Buying
Short: pressure state is Elevated Selling or Extreme Selling
Long: Money Flow Z-Score >= inner sigma
Short: Money Flow Z-Score <= -inner sigma
Long: Money Flow Z-Score crosses above 0
Short: Money Flow Z-Score crosses below 0
Long: pressure state is Extreme Buying AND pressure state[1] is not Extreme Buying
Short: pressure state is Extreme Selling AND pressure state[1] is not Extreme Selling
Long: Money Flow Z-Score > HMA(Money Flow Z-Score, signal lookback) AND Money Flow Z-Score > Money Flow Z-Score[1] AND HMA(Money Flow Z-Score, signal lookback) > HMA(Money Flow Z-Score, signal lookback)[1]
Short: Money Flow Z-Score crosses below HMA(Money Flow Z-Score, signal lookback)
Long: pressure state is Extreme Buying AND HMA(Money Flow Z-Score, signal lookback) > HMA(Money Flow Z-Score, signal lookback)[1]
Short: pressure state is Extreme Selling AND HMA(Money Flow Z-Score, signal lookback) < HMA(Money Flow Z-Score, signal lookback)[1]