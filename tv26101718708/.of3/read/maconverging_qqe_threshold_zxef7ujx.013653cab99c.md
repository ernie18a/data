Calculation: Converging MA = initialize with SMA(close, lookback) and alpha = 0; set alpha to 2 / (lookback + 1) when close crosses the Converging MA; otherwise increase alpha by 1 / increment when close is above the Converging MA and Highest(high, lookback) rises, or close is below it and Lowest(low, lookback) falls; otherwise retain alpha; update the value to its prior value plus prior alpha times the difference between close and its prior value.
Calculation: Fast MA = initialize at close; when close crosses the Converging MA, use the average of close and the prior Fast MA; otherwise, when close is above the Converging MA, use max(close, prior Fast MA) + (close - prior Fast MA) / fast lookback; otherwise use min(close, prior Fast MA) + (close - prior Fast MA) / fast lookback.
Calculation: Smoothed RSI = selected MA(RSI(close, RSI lookback), RSI smoothing lookback, MA type).
Long: Fast MA > Converging MA
Short: Fast MA <= Converging MA
Long: Smoothed RSI > 50 + threshold
Short: Smoothed RSI < 50 - threshold
Short: RSI(close, RSI lookback) < 50 - threshold
Long: Smoothed RSI > 50 + threshold AND Fast MA > Converging MA
Short: RSI(close, RSI lookback) < 50 - threshold AND Smoothed RSI < 50 - threshold AND Fast MA <= Converging MA
Long: Smoothed RSI crosses above 50 + threshold AND Fast MA > Converging MA AND position side is flat or short
Short: Smoothed RSI crosses below 50 - threshold AND Fast MA < Converging MA AND position side is flat or long
Exit: long, Smoothed RSI crosses below 50 - threshold
Exit: short, Smoothed RSI crosses above 50 + threshold
Exit: long, low <= the stored stop set on the long-entry signal bar to that bar's low - ATR(ATR lookback, ATR smoothing) * ATR multiplier
Exit: short, high >= the stored stop set on the short-entry signal bar to that bar's high + ATR(ATR lookback, ATR smoothing) * ATR multiplier