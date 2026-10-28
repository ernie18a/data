Calculation: Fast EMA = exponential moving average of close using a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close using a longer lookback than the fast EMA
Calculation: Bullish market structure = the most recent break direction, updated when close crosses above the latest unbroken confirmed swing high or below the latest unbroken confirmed swing low; swing highs and lows are pivots with equal left and right confirmation lengths
Calculation: Squeeze momentum = linear regression, over a lookback, of close minus the average of (the midpoint of the lookback high and low) and the lookback simple moving average of close
Calculation: Oversold package = at least the configured number of these conditions: Bollinger %b <= its oversold threshold, RSI <= its oversold threshold, smoothed stochastic %K <= its oversold threshold
Calculation: Dip reversal = the oversold package was true on the previous bar and is false now
Calculation: Stop price = entry price × (1 − stop-loss rate)
Calculation: Target price = entry price × (1 + take-profit rate)
Long: flat AND close > slow EMA AND fast EMA > slow EMA AND slow EMA > its value at the rising lookback AND bullish market structure AND squeeze momentum > 0 AND squeeze momentum > its previous value AND dip reversal occurred within the configured entry window AND (RSI confirmation disabled OR RSI > its confirmation level AND RSI > its previous value) AND (ADX filter disabled OR ADX > its minimum AND +DI > −DI) AND (volume filter disabled OR volume is missing OR volume > its moving average × its multiplier)
Exit: long, low <= stop price OR (low > stop price AND high >= target price)
Exit: short, 