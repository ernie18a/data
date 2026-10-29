Calculation: ATR = average true range over a lookback
Calculation: Base range = highest high minus lowest low across the consecutive preceding small-range bars, stopping at the first bar whose high-low range is not less than ATR or at the maximum base-bar count
Calculation: Zone score = rounded impulse-body size divided by base range, clamped to 1–10
Calculation: Opening range high/low = highest high / lowest low during the opening-range session
Long: Close > Open AND Close − Open > impulse-size multiplier × ATR AND at least one consecutive preceding bar has high − low < ATR AND zone score ≥ minimum score
Short: Close < Open AND Open − Close > impulse-size multiplier × ATR AND at least one consecutive preceding bar has high − low < ATR AND zone score ≥ minimum score
Long: Opening range is complete AND no opening-range breakout has occurred this session AND Close > opening range high
Short: Opening range is complete AND no opening-range breakout has occurred this session AND Close < opening range low