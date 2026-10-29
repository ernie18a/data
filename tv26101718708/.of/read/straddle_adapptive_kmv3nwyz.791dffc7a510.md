Calculation: Straddle close = call-option close + put-option close
Calculation: VIX-adjusted threshold = VIX close × a multiplier selected from ascending VIX bands
Calculation: Day low = lowest straddle close for the day, initialized on the first bar and updated from the configured start time while no spike is active
Calculation: Spike peak = highest straddle close since the current spike began
Calculation: Retracement level = spike peak − ((spike peak − day low) × retracement percentage)
Long: At or after the configured start time AND no spike is active AND straddle close ≥ day low × (1 + VIX-adjusted threshold / 100)
Short: A spike is active AND straddle close ≤ retracement level