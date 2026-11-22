Calculation: InWindow = window filter is off OR (datetime >= window start AND datetime <= window end)
Calculation: AODeviation(k) = sum for i = 1..k of first AO deviation * deviation step multiplier^(i - 1)
Calculation: AOSize(k) = first AO size * AO size multiplier^(k - 1)
Calculation: AOFills = number of AO fills since entry
Calculation: AvgEntry = (base order size + sum for k = 1..AOFills of AOSize(k)) / (base order size / entry price + sum for k = 1..AOFills of AOSize(k) / close at AO k fill)
Calculation: TrailLow = lowest close since entry among bars with close <= AvgEntry * (1 - take-profit percent / 100), undefined if there is no such bar
Short: position side is flat AND RSI(close, lookback, T1, last completed bar) crosses below RSI level AND InWindow
Short: position side is short AND AOFills < max AO count AND close >= entry price * (1 + AODeviation(AOFills + 1) / 100) AND InWindow
Exit: short, close >= AvgEntry * (1 + stop-loss percent / 100) AND InWindow
Exit: short, TrailLow is defined AND close >= TrailLow * (1 + trailing percent / 100) AND InWindow