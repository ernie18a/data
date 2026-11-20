Calculation: Swing-leg volume delta percentage = 100 × (sum of volume on bars where close > open − sum of volume on bars where close ≤ open) / max(total volume in the swing leg, minimum volume)
Long: On a newly confirmed PivotHigh(high, swing lookback, swing lookback), its price > the previous confirmed pivot high OR on a newly confirmed PivotLow(low, swing lookback, swing lookback), its price > the previous confirmed pivot low
Short: On a newly confirmed PivotHigh(high, swing lookback, swing lookback), its price ≤ the previous confirmed pivot high OR on a newly confirmed PivotLow(low, swing lookback, swing lookback), its price ≤ the previous confirmed pivot low
Long: On a newly confirmed swing, swing-leg volume delta percentage > delta threshold
Short: On a newly confirmed swing, swing-leg volume delta percentage < −delta threshold
Long: On a newly confirmed swing with a preceding swing node, swing-leg volume delta percentage > 0
Short: On a newly confirmed swing with a preceding swing node, swing-leg volume delta percentage ≤ 0
Long: On a newly confirmed PivotHigh(high, swing lookback, swing lookback), its price > the previous confirmed pivot high AND the preceding trend is bearish
Short: On a newly confirmed PivotLow(low, swing lookback, swing lookback), its price < the previous confirmed pivot low AND the preceding trend is bullish
Long: Bar close is confirmed AND close > the latest confirmed swing high AND the preceding trend is bearish AND the latest confirmed swing high differs from the level of the previous bullish break of structure
Short: Bar close is confirmed AND close < the latest confirmed swing low AND the preceding trend is bullish AND the latest confirmed swing low differs from the level of the previous bearish break of structure