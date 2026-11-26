Calculation: Buy score = floor(100 × count of current-forming-bar measures greater than their preceding completed-bar values across all configured timeframes except the last, divided by six times the number of those timeframes); the six measures are open, high, low, high + low, high + low + close, and high + low + 2 × close; recompute at each panel update
Calculation: Sell score = floor(100 × count of current-forming-bar measures less than or equal to their preceding completed-bar values across all configured timeframes except the last, divided by six times the number of those timeframes); the six measures are open, high, low, high + low, high + low + close, and high + low + 2 × close; recompute at each panel update
Long: Buy score > opening threshold
Short: Sell score > opening threshold
Exit: long, Buy score < closing threshold
Exit: short, Sell score < closing threshold