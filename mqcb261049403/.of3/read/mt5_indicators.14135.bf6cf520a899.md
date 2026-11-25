Calculation: Filter = Σ(w[n] × selected applied price[n]), n = 0…23
Calculation: Anchor = close[round(seconds since midnight ÷ calculation-bar duration) + 1]
Calculation: Trigger = if Filter >= Anchor then Anchor + channel-size parameter × price-point size else Anchor - channel-size parameter × price-point size
Long: Filter > Trigger on chart bars
Short: Filter < Trigger on chart bars
Long: Filter > Trigger using T1 bars, including the bar still forming, sampled at each chart bar's datetime
Short: Filter < Trigger using T1 bars, including the bar still forming, sampled at each chart bar's datetime