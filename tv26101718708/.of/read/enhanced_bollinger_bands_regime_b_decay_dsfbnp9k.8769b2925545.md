Calculation: Adaptive basis = selected SMA, EMA, HMA, KAMA, or VWMA of close
Calculation: Band deviation = standard deviation of close over the basis lookback, or, in asymmetric mode, the greater of half that standard deviation and √2 times the matching upside or downside semi-deviation from the basis
Calculation: Outer bands = adaptive basis ± the selected outer-band multiplier × the matching band deviation
Calculation: Bandwidth percentile = percentile rank of (upper band − lower band) / adaptive basis × 100 over its selected lookback
Calculation: Squeeze = the selected condition: outer bands nested inside a Keltner channel around the adaptive basis, bandwidth percentile below its threshold, or both; the Keltner channel width is its selected multiplier times the SMA of true range or high minus low
Calculation: Active walk = squeeze is false and close has been above the upper band, or below the lower band, for the configured consecutive-bar threshold
Calculation: %B = (close − lower band) / (upper band − lower band)
Calculation: Walk extreme state = on entering an active walk, store its close and %B; on each subsequent new extreme close, compare its %B with the prior stored extreme's %B, increment the consecutive decay count if the decay exceeds the configured minimum, otherwise reset the count, then store the new close and %B; reset the state when no walk is active
Long: active walk-down AND close < stored walk extreme close AND current %B > stored walk extreme %B + configured minimum decay AND consecutive decay count ≥ configured threshold
Short: active walk-up AND close > stored walk extreme close AND current %B < stored walk extreme %B − configured minimum decay AND consecutive decay count ≥ configured threshold