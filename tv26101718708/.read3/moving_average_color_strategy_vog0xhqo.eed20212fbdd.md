Calculation: MA trend state = 1 when rising(selected MA(source price, lookback; MA-type parameter), reaction lookback), -1 when falling(selected MA(source price, lookback; MA-type parameter), reaction lookback), otherwise its prior value (initially 0)
Long: MA trend state > 0
Short: MA trend state < 0