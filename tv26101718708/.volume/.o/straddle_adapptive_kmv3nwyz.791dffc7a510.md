Calculation: straddle close = call option close + put option close
Calculation: day low = lowest straddle close since the configured start time on the current day while flat; initialize to the current close at day start and reset to the exit-bar close after an exit
Calculation: dynamic threshold = VIX close × a multiplier selected by VIX bands, with higher multipliers for higher bands
Calculation: spike high = highest straddle close from the entry bar through the current bar
Calculation: retracement level = spike high − (spike high − day low) × configured retracement fraction
Long: flat AND at or after the configured start time AND straddle close ≥ day low × (1 + dynamic threshold / 100)
Exit: Long, straddle close ≤ retracement level