Calculation: Normalized volume = sum of the last 24 chart bars’ volume divided by the average of the 50 preceding non-overlapping 24-bar volume sums, ending 24 bars ago
Calculation: MACD momentum = (EMA(close, shorter lookback) − EMA(close, longer lookback)) − its value on the previous bar
Calculation: Fast volume signal = EMA(normalized volume, shorter lookback); slow volume signal = EMA(normalized volume, longer lookback)
Calculation: Position signal = 1 when the long condition is true; −1 when the short condition is true; 0 when the volume exit condition is true; otherwise its previous value
Calculation: Long stop price = entry price − entry price ÷ leverage × stop-loss percentage
Calculation: Short stop price = entry price + entry price ÷ leverage × stop-loss percentage
Long: Current normalized volume > threshold AND previous normalized volume ≤ threshold AND current slow volume signal > its previous value AND MACD momentum > 0
Short: Current normalized volume > threshold AND previous normalized volume ≤ threshold AND current slow volume signal > its previous value AND MACD momentum < 0
Exit: Long, slow volume signal > fast volume signal OR absolute change in position signal > 0 OR low ≤ long stop price
Exit: Short, slow volume signal > fast volume signal OR absolute change in position signal > 0 OR high ≥ short stop price