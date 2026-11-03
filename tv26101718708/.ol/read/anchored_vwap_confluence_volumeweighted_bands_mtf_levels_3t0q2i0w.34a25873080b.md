Calculation: Anchored VWAP = volume-weighted average of the selected price source since the selected anchor (the latest swing high or low, or a rolling-window fallback); reset when a new selected swing anchor forms.
Calculation: Anchored volume-weighted standard deviation = square root of the volume-weighted mean of squared source prices minus the squared Anchored VWAP, accumulated from the same anchor.
Calculation: Decayed VWAP = volume-weighted average of the selected price source with exponentially decaying weights; reset when a new selected swing anchor forms, with a shorter effective lookback than the anchored accumulation.
Calculation: Rolling VWAP = volume-weighted average of the selected price source over a fixed rolling window.
Calculation: Efficiency ratio = absolute net close change over a lookback divided by the sum of absolute one-bar close changes over that lookback.
Long: Decayed VWAP crosses above Anchored VWAP AND (regime filter is disabled OR Efficiency ratio > its threshold AND ADX > its threshold)
Short: Decayed VWAP crosses below Anchored VWAP AND (regime filter is disabled OR Efficiency ratio > its threshold AND ADX > its threshold)
Long: Rolling VWAP crosses above Anchored VWAP
Short: Rolling VWAP crosses below Anchored VWAP
Long: (selected price source - Anchored VWAP) / Anchored volume-weighted standard deviation <= negative stretch threshold
Short: (selected price source - Anchored VWAP) / Anchored volume-weighted standard deviation >= stretch threshold