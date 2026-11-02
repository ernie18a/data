Calculation: Stop distance = a configurable absolute distance or entry price multiplied by a configurable percentage; round the resulting stop price to the nearest price tick.
Calculation: Target distance = a configurable absolute distance, entry price multiplied by a configurable percentage, or the rounded stop distance multiplied by a configurable reward-to-risk ratio; round the resulting target price to the nearest price tick.
Long: open = low
Short: open = high AND open > close
Exit: long, bar is after the entry bar AND (low <= entry price - stop distance OR high >= entry price + target distance)
Exit: short, bar is after the entry bar AND (high >= entry price + stop distance OR low <= entry price - target distance)