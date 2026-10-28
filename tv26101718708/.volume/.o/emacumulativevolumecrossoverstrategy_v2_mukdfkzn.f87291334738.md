Calculation: Rolling volume-weighted typical price = sum(((high + low + close) / 3) × volume) / sum(volume), over the cumulative-volume lookback
Calculation: EMA of rolling volume-weighted typical price = EMA of rolling volume-weighted typical price using the same lookback as the EMA of close
Calculation: Longer EMA of rolling volume-weighted typical price = EMA of rolling volume-weighted typical price using twice that EMA lookback
Calculation: Historical EMA of rolling volume-weighted typical price = EMA of rolling volume-weighted typical price shifted back by one EMA lookback, using that same EMA lookback
Long: flat position AND EMA of close crosses above EMA of rolling volume-weighted typical price
Long: long position AND EMA of close > EMA of rolling volume-weighted typical price AND EMA of rolling volume-weighted typical price > longer EMA of rolling volume-weighted typical price AND close crosses above longer EMA of rolling volume-weighted typical price AND close > open
Short: EMA of close crosses below EMA of rolling volume-weighted typical price
Exit: Long, close >= 1% above average entry price AND RSI(5) crosses below 90
Exit: Long, EMA of close crosses below EMA of rolling volume-weighted typical price OR close < average entry price × (1 − stop-loss percentage)
Exit: Short, RSI(5) crosses above 15
Exit: Short, EMA of close crosses above EMA of rolling volume-weighted typical price