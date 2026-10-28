Calculation: Fast EMA = exponential moving average of close with a shorter lookback than Slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than Fast EMA
Calculation: Volume MA = simple moving average of volume
Calculation: Daily running high = highest high from the start of the current day through the current bar
Calculation: Daily running low = lowest low from the start of the current day through the current bar
Long: (close crosses above Daily running high OR close crosses above Fast EMA) AND Fast EMA > Slow EMA AND volume > Volume MA
Short: (close crosses below Daily running low OR close crosses below Fast EMA) AND Fast EMA < Slow EMA AND volume > Volume MA