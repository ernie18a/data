Calculation: ATR = average true range over a lookback
Calculation: Base high = highest high of the prior base lookback bars, excluding the current bar
Calculation: Base low = lowest low of the prior base lookback bars, excluding the current bar
Calculation: Relative volume = current volume / average volume over a lookback
Calculation: Body ratio = absolute(close − open) / (high − low)
Calculation: Active base = the most recently locked breakout base, with its direction and edges, until lost or expired; a new confirmed breakout replaces it
Calculation: Defense edge = active base high for a bullish base; active base low for a bearish base
Calculation: Defense zone = defense edge ± ATR × defense-zone width, using ATR on the breakout bar
Calculation: Failure shelf = below the defense zone by ATR × failure buffer for a bullish base; above it for a bearish base, using ATR on the breakout bar
Long: confirmed close > base high + ATR × break buffer AND prior close ≤ base high + ATR × break buffer AND base high − base low is within the minimum and maximum ATR-based base widths AND body ratio ≥ minimum AND relative volume ≥ minimum
Short: confirmed close < base low − ATR × break buffer AND prior close ≥ base low − ATR × break buffer AND base high − base low is within the minimum and maximum ATR-based base widths AND body ratio ≥ minimum AND relative volume ≥ minimum
Long: active bullish base AND confirmed low ≤ defense-zone top AND close > defense edge AND close > open AND prior bar did not meet these defense conditions
Short: active bearish base AND confirmed high ≥ defense-zone bottom AND close < defense edge AND close < open AND prior bar did not meet these defense conditions
Exit: long, active bullish base AND confirmed close < failure shelf
Exit: short, active bearish base AND confirmed close > failure shelf