Calculation: TSI = 100 × a second smoothing of the first-smoothed close-to-close change divided by a second smoothing of the first-smoothed absolute close-to-close change; use the same two smoothing stages for numerator and denominator.
Calculation: Trigger = TSI from a prior bar on the configured indicator timeframe, which may be higher or lower than the chart timeframe; evaluate only completed bars.
Long: TSI > Trigger AND prior-bar TSI ≤ prior-bar Trigger
Short: TSI < Trigger AND prior-bar TSI ≥ prior-bar Trigger
Exit: long position, TSI < Trigger AND prior-bar TSI ≥ prior-bar Trigger
Exit: short position, TSI > Trigger AND prior-bar TSI ≤ prior-bar Trigger