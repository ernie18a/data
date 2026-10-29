Calculation: Estimated ask and bid volume per price slot = divide each lower-timeframe bar’s volume equally among the slots touched by its low-to-high range; add it to ask if that bar’s close is at least its open, otherwise to bid. If no lower-timeframe bars are available, divide chart-bar volume equally across all slots and assign it to ask if chart close is at least open, otherwise to bid. Use bars from a timeframe lower than the chart timeframe; for a completed chart bar use its available lower-timeframe bars, and for a forming chart bar use the available bars, including any still forming.
Calculation: Slot delta = estimated ask volume minus estimated bid volume in that slot.
Calculation: Bar delta = sum of slot deltas across the chart bar’s slots.
Long: Slot delta > 0
Long: Estimated ask volume in a slot >= imbalance ratio × estimated bid volume in the immediately lower slot, and that lower slot’s estimated bid volume > 0
Long: Bar delta >= 0
Long: Bar delta > 0 AND estimated ask volume across the bar > estimated bid volume across the bar
Short: Slot delta < 0
Short: Estimated bid volume in a slot >= imbalance ratio × estimated ask volume in the immediately higher slot, and that higher slot’s estimated ask volume > 0
Short: Bar delta < 0
Short: Bar delta < 0 AND estimated bid volume across the bar > estimated ask volume across the bar