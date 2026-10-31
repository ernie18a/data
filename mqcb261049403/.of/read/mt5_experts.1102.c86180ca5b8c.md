Calculation: Selling pressure and buying pressure = for each indicator-timeframe bar, let range = high - low, body = open - close, unit = range / volume, replaced by 1 if unit is zero, and swing = (range + abs(body)) / (2 * unit). Selling pressure = swing + max(body, 0) / unit; buying pressure = swing + max(-body, 0) / unit. Volume must be positive.
Calculation: Smoothed selling pressure and smoothed buying pressure = apply the same moving-average method and parameters to the respective pressure series. The indicator timeframe may be the chart timeframe, higher, or lower; use the last completed indicator bar or the still-forming indicator bar according to the signal-bar setting, and compare with the preceding indicator bar for crossings.
Long: Smoothed buying pressure > smoothed selling pressure AND previous smoothed buying pressure <= previous smoothed selling pressure
Short: Smoothed buying pressure < smoothed selling pressure AND previous smoothed buying pressure >= previous smoothed selling pressure
Exit: long, smoothed buying pressure < smoothed selling pressure
Exit: short, smoothed buying pressure > smoothed selling pressure
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance