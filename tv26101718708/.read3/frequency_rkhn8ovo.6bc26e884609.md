Calculation: centerline = selected EMA(close, center lookback), SMA(close, center lookback), VWAP(close), or close
Calculation: phase wave = centerline + (selected ATR(ATR lookback) or fixed amplitude) * amplitude multiplier * sin(2π * bar index / cycle length + phase shift)
Long: phase wave > phase wave[1]
Short: phase wave < phase wave[1]
Long: phase wave crosses above centerline
Short: phase wave crosses below centerline