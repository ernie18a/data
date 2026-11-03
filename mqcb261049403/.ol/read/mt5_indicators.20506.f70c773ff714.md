Calculation: VACC = 100 × sum over the lookback of [volume × (2 × close − high − low) / (high − low)] / sum of volume; use 0 for a bar’s numerator when high = low.
Long: current-bar VACC ≥ previous-bar VACC
Short: current-bar VACC < previous-bar VACC