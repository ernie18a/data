Calculation: point size = minimum price increment of the instrument
Calculation: bid = close of the current bar
Calculation: ask = close of the current bar
Calculation: hour = hour of the datetime of the current bar
Calculation: ref_open = open of the reference-timeframe bar still forming
Calculation: ref_high = highest high from the start of the reference-timeframe bar still forming through the current bar
Calculation: ref_low = lowest low from the start of the reference-timeframe bar still forming through the current bar
Long: position side = flat AND bid > ref_open AND (ref_open - ref_low) > range multiplier * point size AND hour < entry cutoff hour
Short: position side = flat AND ask < ref_open AND (ref_high - ref_open) > range multiplier * point size AND hour < entry cutoff hour
Exit: long, hour > market close hour - 1
Exit: short, hour > market close hour - 1