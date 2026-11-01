Calculation: Trend score = sign(shorter-period moving average of close − longer-period moving average of close) + sign(shorter-period RSI of weighted price − longer-period RSI of median price), where weighted price = (high + low + 2 × close) / 4, median price = (high + low) / 2, and sign is −1, 0, or 1 according to whether its argument is negative, zero, or positive. Moving-average methods and applied prices are configurable.
Calculation: Signal trend score = trend score on a configurable indicator timeframe, which may be higher or lower than the chart timeframe or the same; use the last completed indicator bar by default, or the still-forming bar when configured.
Long: chart-timeframe trend score > 0
Short: chart-timeframe trend score < 0
Long: signal trend score > 0 AND the most recent earlier nonzero signal trend score < 0 AND position side = flat
Short: signal trend score < 0 AND the most recent earlier nonzero signal trend score > 0 AND position side = flat
Exit: long, signal trend score < 0 OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, signal trend score > 0 OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance