Calculation: Pressure = 100 × (source − moving average of source) / highest absolute value of (source − moving average of source) over the normalization lookback. Use a selectable price source and SMA, EMA, RMA, WMA, or VWMA; treat a zero denominator as undefined.
Calculation: Pressure signal = EMA of pressure using the signal smoothing length.
Calculation: Pressure slope = pressure signal − previous bar's pressure signal.
Calculation: Pressure median = SMA of pressure signal over the greater of a minimum lookback and twice the signal smoothing length.
Calculation: Candidate state = +3 if pressure signal >= positive extreme threshold; otherwise −3 if pressure signal <= negative extreme threshold; otherwise +2 if pressure slope > 0 AND pressure signal > positive warning threshold; otherwise −2 if pressure slope < 0 AND pressure signal < negative warning threshold; otherwise 0 if absolute pressure slope < slope threshold AND absolute pressure signal < warning threshold × compression factor; otherwise +1 if pressure signal > 0; otherwise −1 if pressure signal < 0; otherwise 0. Negative thresholds are the negatives of their corresponding positive thresholds.
Calculation: Active state = initially 0. On each completed bar, if candidate state differs from active state, set pending state to candidate state and pending bar to the current bar. Then, if pending state differs from active state AND current bar index − pending bar index >= hold length, set active state to pending state and clear pending state and pending bar. Finally, if active state is 0, set it to candidate state. Initially pending state is 0 and pending bar is unset; when unset, use the current bar index in the elapsed-bar comparison.
Long: Pressure signal crosses above 0.
Short: Pressure signal crosses below 0.
Long: Previous pressure <= negative extreme threshold AND pressure > negative extreme threshold.
Short: Previous pressure >= positive extreme threshold AND pressure < positive extreme threshold.
Long: Pressure signal > positive warning threshold AND pressure > pressure signal.
Short: Pressure signal < negative warning threshold AND pressure < pressure signal.
Long: Active state > 0.
Short: Active state < 0.
Long: Active state > 0 AND pressure signal >= pressure median.
Short: Active state < 0 AND pressure signal <= pressure median.
Long: Active state > previous active state.
Short: Active state < previous active state.
Long: Active state = −3 AND pressure signal > negative warning threshold.
Short: Active state = +3 AND pressure signal < positive warning threshold.