Calculation: Source = selected chart-bar open, high, low, close, (high + low) / 2, (high + low + close) / 3, or (open + high + low + close) / 4; use the same selection throughout.
Calculation: Upper band = maximum of the shorter-period SMA and longer-period EMA of Source.
Calculation: Lower band = minimum of the shorter-period SMA and longer-period EMA of Source.
Long: Source > upper band OR (neutral inside-band mode is disabled AND lower band <= Source <= upper band AND the most recent bar outside the band had Source > upper band).
Short: Source < lower band OR (neutral inside-band mode is disabled AND lower band <= Source <= upper band AND the most recent bar outside the band had Source < lower band).