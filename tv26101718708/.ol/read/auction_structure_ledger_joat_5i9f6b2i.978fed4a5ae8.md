Calculation: Confirmed pivot high/low = a high/low with the configured number of bars on both sides; available only after the right-side bars complete
Calculation: Pivot cluster count = number of confirmed pivots of the same type within the cluster lookback whose prices are within ATR × cluster tolerance of the current confirmed pivot
Calculation: Active support/resistance count = number of unexpired support/resistance shelves; remove the oldest when the shelf limit is exceeded and remove a shelf after its close crosses its invalidation edge for more than the configured lifecycle buffer
Calculation: Price confluence = volume at the close-price bin divided by the greatest volume in the rolling close-price-bin distribution, multiplied by 100; bin the rolling window's volume by close price across the window's low-to-high range
Calculation: Shelf overlap = an active shelf of the same type has a midpoint within ATR × cluster tolerance of the candidate shelf midpoint
Long: Active support count > active resistance count AND price confluence >= confluence threshold
Long: Confirmed pivot low exists AND pivot cluster count >= 2
Long: Active support count > active resistance count
Long: Price confluence >= confluence threshold
Short: Active resistance count > active support count AND price confluence < confluence threshold
Short: Confirmed pivot high exists AND pivot cluster count >= 2
Short: Active resistance count > active support count
Short: Price confluence < confluence threshold