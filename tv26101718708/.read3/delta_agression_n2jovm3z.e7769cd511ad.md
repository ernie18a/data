Calculation: Estimated delta = on each chart bar, if high > low then volume * ((close - low) - (high - close)) / (high - low), otherwise 0
Calculation: Aggression ratio = if SMA(ABS(estimated delta), delta lookback) > 0 then ABS(estimated delta) / SMA(ABS(estimated delta), delta lookback), otherwise 0
Calculation: Delta change = estimated delta - estimated delta[1]
Calculation: Shock ratio = if SMA(ABS(delta change), shock lookback) > 0 then ABS(delta change) / SMA(ABS(delta change), shock lookback), otherwise 0
Calculation: Volume passes = volume filter is disabled OR volume >= SMA(volume, volume average lookback) * minimum volume multiple
Long: confirmed chart bar AND estimated delta > 0 AND aggression ratio >= spike threshold AND volume passes
Short: confirmed chart bar AND estimated delta < 0 AND aggression ratio >= spike threshold AND volume passes
Long: confirmed chart bar AND estimated delta > 0 AND aggression ratio >= extreme threshold AND volume passes
Short: confirmed chart bar AND estimated delta < 0 AND aggression ratio >= extreme threshold AND volume passes
Long: confirmed chart bar AND estimated delta > 0 AND estimated delta[1] > 0 AND estimated delta[2] > 0 AND estimated delta > estimated delta[1] AND estimated delta[1] > estimated delta[2] AND volume passes
Short: confirmed chart bar AND estimated delta < 0 AND estimated delta[1] < 0 AND estimated delta[2] < 0 AND ABS(estimated delta) > ABS(estimated delta[1]) AND ABS(estimated delta[1]) > ABS(estimated delta[2]) AND volume passes
Long: confirmed chart bar AND delta change > 0 AND shock ratio >= shock threshold AND volume passes
Short: confirmed chart bar AND delta change < 0 AND shock ratio >= shock threshold AND volume passes
Long: confirmed chart bar AND estimated delta[1] < 0 AND estimated delta > 0 AND shock ratio >= flip threshold AND volume passes
Short: confirmed chart bar AND estimated delta[1] > 0 AND estimated delta < 0 AND shock ratio >= flip threshold AND volume passes