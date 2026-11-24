Calculation: invalidation price = close when close-based invalidation is selected; high for resistance and low for support when wick-based invalidation is selected
Long: valid support level AND low <= support level AND close > support level AND invalidation price >= support level
Short: valid resistance level AND high >= resistance level AND close < resistance level AND invalidation price <= resistance level
Long: valid resistance level AND invalidation price > resistance level AND (volume break filter disabled OR volume >= SMA(volume, volume-average lookback) × break-volume multiplier)
Short: valid support level AND invalidation price < support level AND (volume break filter disabled OR volume >= SMA(volume, volume-average lookback) × break-volume multiplier)