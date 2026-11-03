Calculation: Event-reset VWAP basis = cumulative sum of source × volume divided by cumulative volume since the latest reset event
Calculation: Upper and lower VWAP bands = VWAP basis plus or minus weighted standard deviation of source from the basis, multiplied by the band-width multiplier
Calculation: Highest since long entry = highest high from the long entry bar through the current bar
Calculation: Lowest since short entry = lowest low from the short entry bar through the current bar
Long: EMA(close) > VWAP basis AND previous EMA(close) ≤ previous VWAP basis
Short: EMA(close) < VWAP basis AND previous EMA(close) ≥ previous VWAP basis
Exit: long, high ≥ upper VWAP band OR trailing take-profit is enabled AND highest since long entry has risen from entry price by at least the activation-profit threshold AND close ≤ highest since long entry × (1 − trailing-distance percentage)
Exit: short, low ≤ lower VWAP band OR trailing take-profit is enabled AND lowest since short entry has fallen from entry price by at least the activation-profit threshold AND close ≥ lowest since short entry × (1 + trailing-distance percentage)