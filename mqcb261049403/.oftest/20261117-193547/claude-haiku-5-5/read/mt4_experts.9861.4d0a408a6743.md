Calculation: reference open = open of the still-forming bar on the reference timeframe
Calculation: reference high = high of the still-forming bar on the reference timeframe
Calculation: reference low = low of the still-forming bar on the reference timeframe
Calculation: bar hour = hour of the bar's datetime
Long: position side is flat AND close > reference open AND reference open - reference low > long range threshold AND bar hour < long entry hour limit
Short: position side is flat AND close < reference open AND reference high - reference open > short range threshold AND bar hour < short entry hour limit
Exit: long, bar hour >= exit hour
Exit: short, bar hour >= exit hour