Calculation: Intensity magnitude = volume, or volume divided by bar duration when the volume-rate basis is selected
Calculation: Delta buy volume = sum of lower-timeframe bar volume where close > open, using lower-timeframe bars within the current chart bar
Calculation: Delta sell volume = sum of lower-timeframe bar volume where close < open, using lower-timeframe bars within the current chart bar
Calculation: Delta ratio = (Delta buy volume - Delta sell volume) / total lower-timeframe volume within the current chart bar; 0 when total volume is 0
Calculation: Unified anomaly threshold = selected method applied to the prior lookback bars of unified magnitude: rolling mean + multiplier × rolling standard deviation; or rolling median + multiplier × rolling median absolute deviation × 1.4826; or the selected rolling percentile. For the higher tier, use a greater multiplier or percentile than for the lower tier.
Calculation: Parallel side thresholds = selected method applied separately to prior lookback bars of each side's magnitude, using the same threshold method and tier relationship as the unified threshold
Calculation: Parallel intensity buy magnitude = intensity magnitude × (close - low) / (high - low); use half the intensity magnitude when high = low
Calculation: Parallel intensity sell magnitude = intensity magnitude × (high - close) / (high - low); use half the intensity magnitude when high = low
Calculation: Parallel excess = (side magnitude - its crossed threshold) / rolling standard deviation for the standard-deviation method; divide by rolling median absolute deviation for the median-deviation method; divide by the threshold for the percentile method. Compare each side against its higher-tier threshold if crossed, otherwise its lower-tier threshold.
Calculation: Close position = 2 × (close - low) / (high - low) - 1; 0 when high = low
Long: unified magnitude > unified anomaly threshold AND ((intensity engine is selected AND close > open) OR (delta engine is selected AND Delta buy volume - Delta sell volume >= 0))
Long: parallel buy magnitude > parallel buy threshold AND (parallel sell magnitude <= parallel sell threshold OR parallel buy excess >= parallel sell excess) AND (delta engine is selected OR close != open)
Long: a Delta-engine anomaly fires AND Close position > 0 AND Delta ratio < 0
Short: unified magnitude > unified anomaly threshold AND ((intensity engine is selected AND close < open) OR (delta engine is selected AND Delta buy volume - Delta sell volume < 0))
Short: parallel sell magnitude > parallel sell threshold AND (parallel buy magnitude <= parallel buy threshold OR parallel sell excess > parallel buy excess) AND (delta engine is selected OR close != open)
Short: a Delta-engine anomaly fires AND Close position < 0 AND Delta ratio > 0