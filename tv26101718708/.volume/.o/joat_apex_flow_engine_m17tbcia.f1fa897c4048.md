Calculation: Efficiency ratio = absolute close change over the flow lookback divided by the sum of absolute one-bar close changes over that lookback
Calculation: Flow baseline = first close, then prior baseline + min(1, (efficiency ratio × (2/3 − 2/31) + 2/31)² × acceleration) × (close − prior baseline)
Calculation: Flow bands = flow baseline ± ATR × envelope width
Calculation: Flow state = bullish after the required consecutive closes above the upper band when the prior state is not bullish; bearish after the required consecutive closes below the lower band when the prior state is not bearish; reset each consecutive-close count when its condition fails
Calculation: Flow quality = directional momentum points (25 if momentum over its lookback is positive for long or negative for short, otherwise 0) + volume points (25 if volume / its longer-lookback average ≥ 1.2; 15 if ≥ 1; otherwise 0) + body points (25 if |close − open| / max(high − low, minimum price increment) ≥ 0.6; 15 if ≥ 0.4; otherwise 5) + efficiency points (25 if efficiency ratio ≥ 0.4; 15 if ≥ 0.25; otherwise 5)
Calculation: Risk distance = ATR × stop multiplier or entry price × stop percentage; long stop = entry price − risk distance and short stop = entry price + risk distance; targets are entry price ± risk distance × each configured reward-to-risk multiple, in the position direction
Long: flow state changes to bullish AND (quality filter disabled OR long flow quality ≥ minimum quality)
Short: flow state changes to bearish AND (quality filter disabled OR short flow quality ≥ minimum quality)
Exit: long, after the entry bar, low ≤ long stop OR high ≥ the furthest enabled long target
Exit: short, after the entry bar, high ≥ short stop OR low ≤ the furthest enabled short target