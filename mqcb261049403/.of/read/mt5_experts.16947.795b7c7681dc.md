Calculation: Fisher = for each bar, let p = (high + low) / 2, H and L be the highest and lowest p over the lookback including that bar, and v = clamp((p - L) / (H - L) - 0.5 + 0.5 × previous v, -0.9999, 0.9999) when H > L, otherwise 0; Fisher = 0.25 × ln((1 + v) / (1 - v)) + 0.5 × previous Fisher. Initialize previous v and previous Fisher to 0. Trigger = previous Fisher.
Calculation: Slow Fisher and trigger = Fisher and trigger on a higher timeframe, using the last completed bar. Fast Fisher and trigger = Fisher and trigger on the chart timeframe, using the last completed bar. Their lookbacks are independently configurable.
Long: Slow Fisher > slow trigger AND fast Fisher on the preceding bar <= fast trigger on the preceding bar AND fast Fisher > fast trigger.
Short: Slow Fisher < slow trigger AND fast Fisher on the preceding bar >= fast trigger on the preceding bar AND fast Fisher < fast trigger.
Exit: long, slow Fisher < slow trigger OR fast Fisher < fast trigger.
Exit: short, slow Fisher > slow trigger OR fast Fisher > fast trigger.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.