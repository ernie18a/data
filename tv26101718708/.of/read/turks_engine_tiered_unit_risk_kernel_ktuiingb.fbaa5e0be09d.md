Calculation: Ensemble exposure = average of four 0-to-1 ramps, one per SMA with progressively longer lookbacks; each ramp is close minus its SMA divided by ATR times a width that increases with the SMA lookback, clipped to [0,1].
Calculation: NWE mean = causal Gaussian-weighted average of the current and preceding source bars.
Calculation: NWE bands = NWE mean ± mean absolute deviation of source from NWE mean over a lookback, multiplied by separate upper- and lower-band width parameters.
Long: Ensemble exposure rung increases from its previously held rung
Long: Source crosses below the lower NWE band from at or above it AND fewer than all sell rungs are held out
Exit: long, source crosses above the upper NWE band from at or below it AND at least one sell rung remains
Exit: long, target weight decreases from its previous value
Exit: long, exposure unit is zero
Short: none