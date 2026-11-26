Calculation: Candle buying pressure (%) = 100 × clamp(0, 1, close-location weight × (close − low) / range + wick weight × (1 + ((min(open, close) − low) − (high − max(open, close))) / range) / 2), where range = high − low unless high = low, then range floor
Calculation: Directional relative-volume delta = (2 × candle buying pressure / 100 − 1) × volume / SMA(volume, volume-average lookback)
Calculation: Relative-volume percentage delta = directional relative-volume delta / (volume / SMA(volume, volume-average lookback)) × 100
Calculation: Signed pressure spike = directional relative-volume delta / SMA(abs(directional relative-volume delta), spike-average lookback), or 0 when that SMA equals 0
Long: Candle buying pressure >= pressure alert threshold A
Short: Candle buying pressure < pressure alert threshold A
Long: Candle buying pressure >= pressure alert threshold B
Short: Candle buying pressure < pressure alert threshold B
Long: Candle buying pressure >= pressure alert threshold C
Short: Candle buying pressure < pressure alert threshold C
Long: Candle buying pressure >= pressure alert threshold D
Short: Candle buying pressure < pressure alert threshold D
Long: Candle buying pressure >= pressure alert threshold E
Short: Candle buying pressure < pressure alert threshold E
Long: Candle buying pressure >= pressure alert threshold F
Short: Candle buying pressure < pressure alert threshold F
Long: Candle buying pressure > pressure alert threshold B
Short: Candle buying pressure <= pressure bearish-color boundary
Long: Directional relative-volume delta >= directional-delta alert threshold A
Short: Directional relative-volume delta < directional-delta alert threshold A
Long: Directional relative-volume delta >= directional-delta alert threshold B
Short: Directional relative-volume delta < directional-delta alert threshold B
Long: Directional relative-volume delta >= directional-delta alert threshold C
Short: Directional relative-volume delta < directional-delta alert threshold C
Long: Directional relative-volume delta > directional-balance boundary
Short: Directional relative-volume delta <= directional-balance boundary
Long: Relative-volume percentage delta >= relative-volume-percentage alert threshold A
Short: Relative-volume percentage delta < relative-volume-percentage alert threshold A
Long: Relative-volume percentage delta >= relative-volume-percentage alert threshold B
Short: Relative-volume percentage delta < relative-volume-percentage alert threshold B
Long: Relative-volume percentage delta > relative-volume-percentage alert threshold A
Short: Relative-volume percentage delta < relative-volume-percentage balance boundary
Long: Signed pressure spike > positive-spike color threshold
Short: Signed pressure spike < spike balance boundary