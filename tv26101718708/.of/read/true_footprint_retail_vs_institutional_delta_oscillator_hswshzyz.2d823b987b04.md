Calculation: True delta = ((close − open) ÷ (high − low, or 1 when high = low)) × volume
Calculation: Normalized institutional flow = 100 × institutional EMA ÷ rolling 100-bar maximum of the absolute institutional and retail EMA values; institutional EMA input is true delta when volume > 20-bar SMA(volume) × threshold, otherwise 5% of true delta
Calculation: Normalized retail flow = 100 × retail EMA ÷ the same rolling 100-bar maximum; retail EMA input is 10% of true delta when volume > 20-bar SMA(volume) × threshold, otherwise true delta; the institutional EMA lookback is longer than the retail EMA lookback
Long: Normalized retail flow < −20 AND normalized institutional flow > 10 AND close ≥ open
Short: Normalized retail flow > 20 AND normalized institutional flow < −10 AND close ≤ open