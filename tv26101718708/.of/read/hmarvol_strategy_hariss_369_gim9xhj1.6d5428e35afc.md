Calculation: RVOL = current bar volume divided by the simple moving average of volume over the lookback ending on the previous bar
Long: close > Hull Moving Average of close AND RVOL > RVOL threshold
Short: close < Hull Moving Average of close AND RVOL > RVOL threshold
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage)