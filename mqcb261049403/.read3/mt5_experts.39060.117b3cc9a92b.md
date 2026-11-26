Calculation: long-position net profit = sum(profit + commission + swap for each open long position)
Calculation: short-position net profit = sum(profit + commission + swap for each open short position)
Long: (DeMarker(lookback)[1] < lower threshold AND reverse mode disabled) OR (DeMarker(lookback)[1] > upper threshold AND reverse mode enabled)
Short: (DeMarker(lookback)[1] > upper threshold AND reverse mode disabled) OR (DeMarker(lookback)[1] < lower threshold AND reverse mode enabled)
Exit: long, ((DeMarker(lookback)[1] > upper threshold AND reverse mode disabled) OR (DeMarker(lookback)[1] < lower threshold AND reverse mode enabled)) AND long-position net profit > 0
Exit: short, ((DeMarker(lookback)[1] < lower threshold AND reverse mode disabled) OR (DeMarker(lookback)[1] > upper threshold AND reverse mode enabled)) AND short-position net profit > 0