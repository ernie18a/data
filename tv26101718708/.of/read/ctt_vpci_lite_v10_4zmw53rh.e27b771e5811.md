Calculation: Daily price change percentage = (current close − previous completed daily close) / previous completed daily close × 100; use daily bars aggregated from the input bars, with the current daily bar still forming.
Calculation: Relative volume = current volume of the still-forming daily bar divided by the selected prior daily volume baseline (one prior day, or a 5-, 10-, or 21-day average; the 5+10-day option weights the 5-day average 60% and the 10-day average 40%). During regular trading hours, scale the average baseline by the session U-shaped progress adjustment.
Long: Daily price change percentage > 0
Short: Daily price change percentage ≤ 0
Long: Relative volume ≥ 1.5
Long: close ≥ open
Short: close < open
Long: 14-period RSI ≤ 30
Short: 14-period RSI ≥ 70