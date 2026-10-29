Calculation: Silver/gold edge = 100 × (1 − (gold close / silver close) / (gold baseline / silver baseline)); calculate each metal’s baseline with the same lookback and baseline type (VWMA, falling back to EMA when VWMA is unavailable). Use the selected source timeframe, which may be higher or lower than the chart timeframe; use its current bar, which may still be forming.
Calculation: Edge velocity = EMA of the bar-to-bar change in the silver/gold edge, with a shorter lookback than the baseline.
Calculation: Silver percentile zone = gold/silver ratio at or below its smoothed 20th percentile; gold percentile zone = ratio at or above its smoothed 80th percentile. Calculate percentiles over a longer lookback than the percentile smoothing EMA.
Long: Silver/gold edge crosses above 0
Short: Silver/gold edge crosses below 0
Exit: long, silver regime AND edge velocity < 0 AND (absolute silver/gold edge ≥ strong-edge threshold OR silver percentile zone)
Exit: short, gold regime AND edge velocity > 0 AND (absolute silver/gold edge ≥ strong-edge threshold OR gold percentile zone)