Calculation: normalized MACD histogram = (short-lookback moving average of close − long-lookback moving average of close − its signal moving average) / rolling highest raw MACD histogram × positive scale; the short lookback is shorter than the long lookback, and the signal moving average smooths the MACD difference
Calculation: take-profit price = entry price × (1 + configured profit threshold)
Calculation: stop-loss price = entry price × (1 − configured profit threshold / configured profit-to-loss ratio)
Long: datetime is within the configured trading date range AND at least two of (stochastic %K > %D AND %K > its prior value AND %D > its prior value), (RSI > 50), (normalized MACD histogram > 0 AND > its prior value)
Short: datetime is within the configured trading date range AND at least two of (stochastic %K < %D AND %K < its prior value AND %D < its prior value), (RSI < 50), (normalized MACD histogram < 0 AND < its prior value)
Exit: long, open >= take-profit price OR open <= stop-loss price OR high >= take-profit price OR low <= stop-loss price
Exit: short, open >= take-profit price OR open <= stop-loss price OR high >= take-profit price OR low <= stop-loss price