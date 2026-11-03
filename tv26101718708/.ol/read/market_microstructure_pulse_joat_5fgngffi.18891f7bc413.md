Calculation: Tick direction = for each lower-timeframe bar within the current chart bar, +1 if its close is above the preceding lower-timeframe close, −1 if below, and 0 if equal; the first close is compared with itself. Uses lower-timeframe bars, including the bar still forming.
Calculation: Tick share = up-tick or down-tick count divided by total non-flat ticks in the chart bar.
Calculation: Pulse = EMA of (0.55 × (up-tick count − down-tick count) / total non-flat ticks + 0.45 × (up-tick volume − down-tick volume) / total directional tick volume), clamped to [−1, 1]. Uses current chart-bar data, including lower-timeframe bars still forming.
Calculation: Ask streak = maximum consecutive up-tick count within the chart bar; bid streak = maximum consecutive down-tick count. Flat ticks neither extend nor end a streak.
Calculation: Ending ask/bid streak = consecutive up/down ticks at the end of the chart bar; flat ticks neither extend nor end a streak.
Long: Pulse > 0
Short: Pulse < 0
Long: Pulse crosses above 0
Short: Pulse crosses below 0
Long: Pulse > positive extreme threshold
Short: Pulse < negative extreme threshold
Long: Pulse crosses from at or below the positive extreme threshold to above it AND ending ask streak > ending bid streak AND ask streak >= streak minimum
Short: Pulse crosses from at or above the negative extreme threshold to below it AND ending bid streak > ending ask streak AND bid streak >= streak minimum
Long: Up-tick share >= imbalance threshold AND total non-flat ticks >= 10
Short: Down-tick share >= imbalance threshold AND total non-flat ticks >= 10
Long: Ending ask streak > ending bid streak AND previous chart bar's ending bid streak > previous chart bar's ending ask streak AND ask streak >= streak minimum AND at least 3 chart bars since the previous aggression flip marker
Short: Ending bid streak > ending ask streak AND previous chart bar's ending ask streak > previous chart bar's ending bid streak AND bid streak >= streak minimum AND at least 3 chart bars since the previous aggression flip marker