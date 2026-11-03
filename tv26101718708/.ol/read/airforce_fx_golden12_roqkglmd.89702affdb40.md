Calculation: Fast EMA = exponential moving average of close with a shorter lookback
Calculation: Slow EMA = exponential moving average of close with a longer lookback
Long: Fast EMA > Slow EMA AND absolute difference between Fast EMA and Slow EMA >= minimum gap AND low <= Fast EMA AND previous bar low > previous bar Fast EMA
Long: Fast EMA > Slow EMA AND absolute difference between Fast EMA and Slow EMA >= minimum gap AND low <= Slow EMA AND previous bar low > previous bar Slow EMA
Short: Fast EMA < Slow EMA AND absolute difference between Fast EMA and Slow EMA >= minimum gap AND high >= Fast EMA AND previous bar high < previous bar Fast EMA
Short: Fast EMA < Slow EMA AND absolute difference between Fast EMA and Slow EMA >= minimum gap AND high >= Slow EMA AND previous bar high < previous bar Slow EMA
Exit: Long, high >= entry price + fixed distance OR low <= entry price - the same fixed distance
Exit: Short, low <= entry price - fixed distance OR high >= entry price + the same fixed distance