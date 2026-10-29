Calculation: Buy-volume weight = (close - low) / (high - low); use 0.5 when high = low
Calculation: Confirmed pivot high/low = a bar's high/low is higher/lower than the highs/lows of the specified number of bars on both sides
Long: Close crosses above the latest active confirmed pivot high
Short: Close crosses below the latest active confirmed pivot low
Long: Buy-volume weight > 0.65
Short: Buy-volume weight < 0.35
Long: MACD line > MACD signal line
Short: MACD line <= MACD signal line
Long: Fisher Transform > its prior value
Short: Fisher Transform <= its prior value
Long: Money Flow Index > 50
Exit: long, Money Flow Index <= 50
Exit: short, Money Flow Index <= 50