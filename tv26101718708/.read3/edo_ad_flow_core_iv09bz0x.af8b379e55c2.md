Calculation: Normalized flow = cumulative sum of (if high = low then 0, otherwise ((close - open) / (high - low)) × volume), rescaled over the normalization lookback using its rolling highest and lowest to −100..100, or 0 when those extrema are equal
Calculation: Fast flow = EMA or SMA of Normalized flow over the shorter lookback, using the selected moving-average type
Calculation: Slow flow = EMA or SMA of Normalized flow over the longer lookback, using the same selected moving-average type
Calculation: Histogram = Fast flow − Slow flow
Long: Fast flow crosses above Slow flow
Short: Fast flow crosses below Slow flow
Long: Histogram ≥ 0 AND Histogram > Histogram[1]
Long: Histogram ≥ 0 AND Histogram ≤ Histogram[1]
Short: Histogram < 0 AND Histogram < Histogram[1]
Short: Histogram < 0 AND Histogram ≥ Histogram[1]
Long: Divergence display is enabled AND a confirmed bilateral pivot low in Fast flow has low[pivot length] below the previous such pivot's low and Fast flow[pivot length] above its previous pivot value AND the previous confirmed pivot is within the maximum separation; pivot length and maximum separation are selected together by the divergence sensitivity setting
Short: Divergence display is enabled AND a confirmed bilateral pivot high in Fast flow has high[pivot length] above the previous such pivot's high and Fast flow[pivot length] below its previous pivot value AND the previous confirmed pivot is within the maximum separation; pivot length and maximum separation are selected together by the divergence sensitivity setting