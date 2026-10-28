Calculation: First-half VWAP = volume-weighted average of (high + low + close) / 3 across bars in the first half of each custom period, rounded to the nearest tick; updates while that half forms, then is fixed.
Calculation: Second-half VWAP = volume-weighted average of (high + low + close) / 3 across bars in the second half of each custom period, rounded to the nearest tick; updates while that half forms.
Long: Second-half VWAP − first-half VWAP > neutral threshold in ticks
Short: First-half VWAP − second-half VWAP > neutral threshold in ticks