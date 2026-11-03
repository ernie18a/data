Calculation: Opening range high = highest high from the session’s first bar through the last bar of the opening-range period, using the completed higher-timeframe opening-range bar
Calculation: Opening range low = lowest low from the session’s first bar through the last bar of the opening-range period, using the completed higher-timeframe opening-range bar
Calculation: Upper level = opening range high × (1 + buffer percentage)
Calculation: Lower level = opening range low × (1 − buffer percentage)
Calculation: Half range = (upper level − lower level) / 2
Calculation: Long stop = long entry price − half range
Calculation: Long target = long entry price + (half range × risk-reward ratio)
Calculation: Short stop = short entry price + half range
Calculation: Short target = short entry price − (half range × risk-reward ratio)
Long: opening range is complete AND, since its completion, high > upper level followed by low <= upper level followed by high > upper level (these comparisons may occur on the same bar) AND current time <= entry cutoff AND session trade count < maximum trades AND no prior long signal remains uncleared by a stop hit
Short: opening range is complete AND, since its completion, low < lower level followed by high >= lower level followed by low < lower level (these comparisons may occur on the same bar) AND current time <= entry cutoff AND session trade count < maximum trades AND no prior short signal remains uncleared by a stop hit
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target