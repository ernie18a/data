Calculation: Donchian midpoint = (highest high over the channel lookback, including the current bar + lowest low over the same lookback) / 2
Calculation: EMA slope = 10,000 × (current EMA of median price − EMA of median price at the longer bar shift) / (longer shift − current shift)
Long: current high > previous bar’s Donchian upper channel AND EMA slope > threshold OR close crosses above the Donchian midpoint
Short: current low < previous bar’s Donchian lower channel AND EMA slope < −threshold OR close crosses below the Donchian midpoint
Exit: long, low <= Donchian midpoint
Exit: short, high >= Donchian midpoint