Calculation: VWAP control = rolling sum(hlc3 × volume) divided by rolling sum(volume)
Calculation: Control band width = max(rolling standard deviation of (hlc3 − VWAP control) × band multiplier, ATR × band-width floor)
Long: close is above VWAP control + control band width for the acceptance lookback consecutive bars AND (the current accepted control side is not long OR rejection state is active)
Short: close is below VWAP control − control band width for the acceptance lookback consecutive bars AND (the current accepted control side is not short OR rejection state is active)