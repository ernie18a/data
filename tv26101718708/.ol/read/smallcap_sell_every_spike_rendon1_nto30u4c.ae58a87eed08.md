Calculation: Relative volume = current-bar volume / volume SMA
Calculation: Upper-wick percentage = (high − max(open, close)) / (high − low) × 100
Calculation: Float rotation = cumulative volume since session start / float shares
Short: ROC over its lookback ≥ threshold AND high − low ≥ ATR × threshold AND volume > volume SMA × threshold AND high = highest high over the longer of the ROC lookback and a longer lookback
Short: The above conditions AND close within the configured price band AND relative volume ≥ threshold AND float rotation ≤ maximum AND (wick filter disabled OR upper-wick percentage ≥ threshold) AND (VWAP filter disabled OR close crosses below VWAP) AND cooldown elapsed AND trades today below daily cap
Exit: Short, high ≥ entry price + ATR captured at entry × stop multiple
Exit: Short, low ≤ entry price − ATR captured at entry × target multiple
Exit: Short, low ≤ entry price × (1 − target percentage / 100)