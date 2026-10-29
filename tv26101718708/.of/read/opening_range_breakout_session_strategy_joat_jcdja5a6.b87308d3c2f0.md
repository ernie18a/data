Calculation: Opening range high = highest high during the configured opening-range window, fixed when the window ends
Calculation: Opening range low = lowest low during the configured opening-range window, fixed when the window ends
Calculation: Breakout buffer = ATR × configured buffer multiplier
Calculation: Risk distance = ATR × configured stop multiplier when ATR stops are enabled; otherwise, for a long, entry price − opening range low, or for a short, opening range high − entry price; if that distance is nonpositive, use ATR × configured stop multiplier
Calculation: Stop price = long entry price − risk distance; short entry price + risk distance
Calculation: First target = long entry price + risk distance × configured first-target R multiple; short entry price − risk distance × configured first-target R multiple
Long: opening range locked AND inside configured trade session AND trades today < configured daily maximum AND enough chart bars since the previous signal (or no previous signal) AND close > opening range high + breakout buffer AND previous close ≤ previous opening range high + current breakout buffer
Short: opening range locked AND inside configured trade session AND trades today < configured daily maximum AND enough chart bars since the previous signal (or no previous signal) AND close < opening range low − breakout buffer AND previous close ≥ previous opening range low − current breakout buffer
Exit: Long, high ≥ first target OR low ≤ stop price
Exit: Short, low ≤ first target OR high ≥ stop price