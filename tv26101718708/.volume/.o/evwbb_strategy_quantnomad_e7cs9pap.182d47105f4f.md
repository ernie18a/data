Calculation: EVWMA = ((rolling volume sum − current volume) × previous EVWMA + current volume × close) / rolling volume sum; initialize the previous EVWMA as close
Calculation: Upper band = EVWMA + standard deviation of close × multiplier, using the same lookback as the rolling volume sum
Calculation: Lower band = EVWMA − standard deviation of close × multiplier, using the same lookback as the rolling volume sum
Long: upper band is available AND high ≥ upper band
Short: upper band is available AND low ≤ lower band
Exit: long, low ≤ EVWMA
Exit: short, high ≥ EVWMA