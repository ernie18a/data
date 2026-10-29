Calculation: Adjusted directional range = wick-weighted candle position within the true range plus the complementary weight of close change; optionally divide by the true range or previous close, using a positive floor for the divisor
Calculation: Dynamic EFI = EMA(volume × adjusted directional range, lookback)
Calculation: Smoothed EFI = SMA(Dynamic EFI, lookback)
Long: Dynamic EFI > Smoothed EFI
Short: Dynamic EFI <= Smoothed EFI
Long: Smoothed EFI > 0
Short: Smoothed EFI <= 0