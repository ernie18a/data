Calculation: Reference = close of the last completed T1 bar ending at the selected weekday and hour, read on each chart bar
Calculation: Range = selected method: close × price percentage, or ATR(high, low, close, lookback, T2, last completed bar) × ATR percentage
Long: high > Reference + Range
Short: low < Reference - Range
Exit: long, high >= Reference + Range + Range × take-profit percentage OR low <= Reference + Range - Range × stop-loss percentage
Exit: short, low <= Reference - Range - Range × take-profit percentage OR high >= Reference - Range + Range × stop-loss percentage