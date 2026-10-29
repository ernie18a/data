Calculation: Weighted high midpoint = VWMA of the lookback highest high
Calculation: Weighted low midpoint = VWMA of the lookback lowest low
Calculation: Smoothed midpoint = EMA of the average of weighted high midpoint and weighted low midpoint
Calculation: Volume-adjusted midpoint = 3-bar VWMA of smoothed midpoint × (volume / VWMA of volume)
Calculation: Zone width = SMA of weighted high midpoint − weighted low midpoint
Calculation: RSI adjustment = RSI of volume-adjusted midpoint × 0.01 × zone width
Calculation: Upper purchase band = smoothed midpoint + RSI adjustment
Calculation: Lower purchase band = smoothed midpoint − RSI adjustment
Calculation: Basis = average of upper and lower purchase bands
Calculation: Upper stop band = upper purchase band × (1 + stop-loss percentage / 100)
Calculation: Lower stop band = lower purchase band × (1 − stop-loss percentage / 100)
Long: purchase source crosses above the lower purchase band AND long entry is available; availability is set after purchase source crosses below the upper purchase band, or after a stop loss if reset-after-stop-loss is selected, or after purchase source crosses below the lower purchase band if reset-after-entry is selected; availability is cleared on long entry
Short: purchase source crosses below the upper purchase band AND short entry is available; availability is set after purchase source crosses above the lower purchase band, or after a stop loss if reset-after-stop-loss is selected, or after purchase source crosses above the upper purchase band if reset-after-entry is selected; availability is cleared on short entry
Exit: long, exit source crosses above the upper purchase band OR (stop loss is enabled AND exit source crosses below the lower stop band) OR (take profit is enabled AND exit source crosses below the basis after exit source has crossed above the basis since the last exit source cross above the upper purchase band)
Exit: short, exit source crosses below the lower purchase band OR (stop loss is enabled AND exit source crosses above the upper stop band) OR (take profit is enabled AND exit source crosses above the basis after exit source has crossed below the basis since the last exit source cross below the lower purchase band)