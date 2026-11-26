Calculation: BullGap(first-stage MA method, longer first-stage lookback, first-stage phase, second-stage MA method, shorter second-stage lookback, second-stage phase) = MA(high - MA(open, first-stage MA method, longer first-stage lookback, first-stage phase), second-stage MA method, shorter second-stage lookback, second-stage phase) - MA(high - MA(close, first-stage MA method, longer first-stage lookback, first-stage phase), second-stage MA method, shorter second-stage lookback, second-stage phase)[1]
Long: BullGap(chart MA parameters) > 0
Short: BullGap(chart MA parameters) < 0
Long: BullGap(T1, bar still forming, sampled on chart bars, T1 MA parameters) > 0
Short: BullGap(T1, bar still forming, sampled on chart bars, T1 MA parameters) < 0
Long: BullGap(T1, bar still forming, sampled on chart bars, T1 MA parameters)[signal-bar index] > 0 AND BullGap(T1, bar still forming, sampled on chart bars, T1 MA parameters)[signal-bar index + 1] = 0
Short: BullGap(T1, bar still forming, sampled on chart bars, T1 MA parameters)[signal-bar index + 1] > 0 AND BullGap(T1, bar still forming, sampled on chart bars, T1 MA parameters)[signal-bar index] = 0