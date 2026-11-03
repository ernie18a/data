Calculation: Fisher CG oscillator = Apply the Fisher transform 0.5 × ln((1 + 1.98 × (x − 0.5)) / (1 − 1.98 × (x − 0.5))) to x, where x is the weighted average of the current and previous three values of the current bar’s CG position within the highest and lowest CG values over the lookback. CG = (lookback + 1) / 2 − sum((i + 1) × midpoint[i]) / sum(midpoint[i]), where midpoint = (high + low) / 2 and i runs from 0 to lookback − 1, starting with the current bar. CG position = (current CG − lowest CG) / (highest CG − lowest CG). The weighting from current to three bars back is 4:3:2:1. For decisions, use the higher-timeframe oscillator on its still-forming bar.
Calculation: Trigger = previous bar’s Fisher CG oscillator on the same higher timeframe.
Long: Fisher CG oscillator > Trigger
Long: Fisher CG oscillator > 0
Short: Fisher CG oscillator < Trigger
Short: Fisher CG oscillator < 0