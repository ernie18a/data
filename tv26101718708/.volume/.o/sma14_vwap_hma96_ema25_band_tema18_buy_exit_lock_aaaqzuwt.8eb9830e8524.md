Calculation: Green zone = becomes true when SMA crosses above VWAP and close > HMA; while true, becomes false when SMA < VWAP or close < HMA
Calculation: Zone start = Green zone is true now and was false on the prior bar
Calculation: Entry-used-in-zone = resets when Green zone is false; becomes true after a long entry
Calculation: Lock level = once close − entry price ≥ lock trigger, set to entry price + lock profit points and retain until exit
Long: Green zone AND NOT Zone start AND NOT Entry-used-in-zone AND flat AND low ≤ EMA of high AND close ≥ EMA of high
Exit: long, Green zone is false AND was true on the prior bar OR TEMA crosses below SMA OR Lock level is set AND close ≤ Lock level