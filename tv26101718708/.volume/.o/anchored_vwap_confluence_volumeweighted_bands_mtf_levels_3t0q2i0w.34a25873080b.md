Calculation: Auto anchored VWAP = volume-weighted average of HLC3 since the more recent latest confirmed swing high or swing low; before either pivot exists, use rolling VWAP. Confirm pivots using a configurable symmetric lookback.
Calculation: Decayed VWAP = volume-weighted average of HLC3 with exponentially decaying weights, reset when a new selected swing pivot is confirmed.
Calculation: Anchored VWAP sigma = square root of the volume-weighted mean of HLC3 squared since the selected anchor minus the square of anchored VWAP.
Calculation: Stretch z-score = (HLC3 − anchored VWAP) / anchored VWAP sigma.
Calculation: Trending regime = efficiency ratio (absolute net close change over a longer lookback divided by the sum of absolute one-bar close changes over that lookback) exceeds its threshold AND ADX exceeds its threshold.
Long: decayed VWAP crosses above anchored VWAP AND trending regime OR rolling VWAP crosses above anchored VWAP OR stretch z-score is at or below the negative stretch threshold
Short: decayed VWAP crosses below anchored VWAP AND trending regime OR rolling VWAP crosses below anchored VWAP OR stretch z-score is at or above the stretch threshold