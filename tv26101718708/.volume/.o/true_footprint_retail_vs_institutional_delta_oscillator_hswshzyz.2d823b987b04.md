Calculation: True delta = ((close − open) / (high − low)) × volume, using 1 as the range when high = low
Calculation: Average volume = SMA(volume, average-volume lookback)
Calculation: Institutional raw flow = true delta when volume > average volume × institutional volume threshold; otherwise 0.05 × true delta
Calculation: Retail raw flow = 0.1 × true delta when volume > average volume × institutional volume threshold; otherwise true delta
Calculation: Institutional flow = EMA(institutional raw flow, institutional smoothing lookback)
Calculation: Retail flow = EMA(retail raw flow, retail tracking lookback), with the institutional smoothing lookback longer than the retail tracking lookback
Calculation: Normalizer = rolling highest of max(abs(institutional flow), abs(retail flow)) over the normalization lookback; use 1 when zero or undefined
Calculation: Normalized institutional flow = institutional flow / normalizer × 100
Calculation: Normalized retail flow = retail flow / normalizer × 100
Long: normalized retail flow < −20 AND normalized institutional flow > 10 AND close ≥ open
Short: normalized retail flow > 20 AND normalized institutional flow < −10 AND close ≤ open