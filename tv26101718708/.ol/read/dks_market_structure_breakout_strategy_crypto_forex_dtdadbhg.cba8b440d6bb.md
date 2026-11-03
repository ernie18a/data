Calculation: Prior rolling high = highest high over a lookback, excluding the current bar
Calculation: Prior rolling low = lowest low over a lookback, excluding the current bar
Long: short-term EMA > long-term EMA AND close > short-term EMA AND RSI > long-entry threshold AND close > prior rolling high AND volume > volume moving average × volume multiplier
Short: short-term EMA < long-term EMA AND close < short-term EMA AND RSI < short-entry threshold AND close < prior rolling low AND volume > volume moving average × volume multiplier
Exit: long, close ≤ entry price × (1 − stop-loss percentage) OR close ≥ entry price × (1 + take-profit percentage)
Exit: short, close ≥ entry price × (1 + stop-loss percentage) OR close ≤ entry price × (1 − take-profit percentage)