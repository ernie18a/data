Calculation: Force = volume × (high - low)
Calculation: Body ratio = if high > low then abs(close - open) / (high - low) else 0
Calculation: Relative force = if SMA(Force, lookback) > 0 then Force / SMA(Force, lookback) else 0
Long: close > open AND Body ratio >= minimum body ratio AND (Relative force >= vector threshold OR Relative force >= extreme threshold)
Short: close < open AND Body ratio >= minimum body ratio AND (Relative force >= vector threshold OR Relative force >= extreme threshold)