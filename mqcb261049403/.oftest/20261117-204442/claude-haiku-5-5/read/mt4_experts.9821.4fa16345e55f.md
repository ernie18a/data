Calculation: reference_open = open of the bar still forming on the reference timeframe
Calculation: reference_high = high of the bar still forming on the reference timeframe
Calculation: reference_low = low of the bar still forming on the reference timeframe
Calculation: open_low_gap = reference_open - reference_low
Calculation: open_high_gap = reference_high - reference_open
Calculation: bar_hour = hour of the datetime of the current bar
Long: close > reference_open AND open_low_gap > long_gap_threshold AND bar_hour < long_hour_limit AND no position is open
Short: close < reference_open AND open_high_gap > short_gap_threshold AND bar_hour < short_hour_limit AND no position is open
Exit: long, bar_hour >= exit_hour
Exit: short, bar_hour >= exit_hour