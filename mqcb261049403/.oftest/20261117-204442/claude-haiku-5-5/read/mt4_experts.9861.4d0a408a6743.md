Calculation: day_open = open of the daily bar still forming
Calculation: day_high = high of the daily bar still forming
Calculation: day_low = low of the daily bar still forming
Long: position side is flat AND hour of datetime < long-entry hour parameter AND close > day_open AND day_open - day_low > long-entry price-distance parameter
Short: position side is flat AND hour of datetime < short-entry hour parameter AND close < day_open AND day_high - day_open > short-entry price-distance parameter
Exit: long, hour of datetime > market-close hour parameter - 1
Exit: short, hour of datetime > market-close hour parameter - 1