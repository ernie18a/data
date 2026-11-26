Calculation: true delta = footprint delta when available; otherwise ((close - open) / (high - low if high != low else 1)) * volume
Calculation: institutional raw flow = true delta when positive, otherwise true delta * 0.05
Calculation: retail raw flow = true delta * 0.1 when true delta is positive, otherwise true delta
Calculation: normalization maximum = highest(max(abs(EMA(institutional raw flow, institutional smoothing length)), abs(EMA(retail raw flow, retail tracking length))), normalization lookback), replacing zero or na with 1
Calculation: normalized institutional flow = 100 * EMA(institutional raw flow, institutional smoothing length) / normalization maximum
Calculation: normalized retail flow = 100 * EMA(retail raw flow, retail tracking length) / normalization maximum
Long: normalized retail flow < -retail threshold AND normalized institutional flow > institutional threshold AND close >= open
Short: normalized retail flow > retail threshold AND normalized institutional flow < -institutional threshold AND close <= open