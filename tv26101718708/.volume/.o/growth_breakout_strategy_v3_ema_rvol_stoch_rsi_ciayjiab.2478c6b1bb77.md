Calculation: Relative volume = current bar volume divided by the simple average volume over a shorter lookback that includes the current bar
Calculation: Stoch RSI K = the short-term simple average of RSI’s position, scaled 0–100, between its rolling lowest and highest values over a longer lookback; use 0 if those values are equal
Calculation: Stoch RSI D = the short-term simple average of Stoch RSI K
Long: flat AND abs(close − fast EMA) / close ≤ consolidation threshold AND close ≥ rolling highest high × (1 − proximity threshold) AND close > highest high of the preceding breakout lookback bars AND relative volume ≥ threshold AND (fast EMA crosses above slow EMA OR close > fast EMA) AND Stoch RSI K > Stoch RSI D AND Stoch RSI K < maximum
Exit: long, close crosses below slow EMA
Exit: long, close crosses below fast EMA
Exit: long, low ≤ entry price × (1 − stop percentage)
Exit: long, low ≤ entry price × (1 − stop percentage) OR high ≥ entry price × (1 + target percentage)
Exit: long, low ≤ entry price − current ATR × stop multiple
Exit: long, low ≤ entry price − current ATR × stop multiple OR high ≥ entry price + current ATR × target multiple