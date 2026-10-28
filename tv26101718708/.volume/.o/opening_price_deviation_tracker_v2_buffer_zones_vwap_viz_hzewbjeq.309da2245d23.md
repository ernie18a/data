Calculation: Anchor-period open = the open of the first chart bar of the current anchor period, held until the next period begins.
Calculation: Deviation level k = anchor-period open × (1 + k × step / 100), for positive k above the open and negative k below it; use the current anchor period.
Long: First reach of a lower deviation level in the current anchor period AND the bar closes at or above that level AND (close − level) / max(high − low, minimum price increment) ≥ rejection-wick threshold.
Long: First reach of an upper deviation level in the current anchor period AND the bar closes above that level.
Short: First reach of an upper deviation level in the current anchor period AND the bar closes at or below that level AND (level − close) / max(high − low, minimum price increment) ≥ rejection-wick threshold.
Short: First reach of a lower deviation level in the current anchor period AND the bar closes below that level.