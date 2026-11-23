Calculation: robust z(x) = (x - MEDIAN(x, distribution window)) / (1.4826 * MEDIAN(ABS(x - MEDIAN(x, distribution window)), distribution window) + ε)
Calculation: raw effort = volume if effort source is not range-only AND volume is usable (not NA AND SMA(volume, usability window) > 0), else TR
Calculation: effort baseline = IF intraday AND seasonal normalization enabled AND the bar's minute-of-day slot has at least minimum seasonal samples THEN the slot's stored average before this bar ELSE EMA(raw effort, fallback window); on intraday bars with seasonal normalization enabled, afterwards the slot's stored average becomes raw effort if empty, otherwise stored average + 2 / (seasonal memory + 1) * (raw effort - stored average), and the slot's sample count increases by 1
Calculation: effort = SMA(MIN(effort cap, raw effort / (effort baseline + ε)), gravity window)
Calculation: log return = LN(close / close[1])
Calculation: signed net log move = LN(close / close[gravity window])
Calculation: expected move = STDEV(log return, volatility window) * SQRT(gravity window)
Calculation: displacement = ABS(signed net log move) / (expected move + ε)
Calculation: path efficiency = MIN(1, ABS(signed net log move) / (SUM(ABS(log return), gravity window) + ε))
Calculation: raw gravity = LN(1 + effort) - LN(displacement + ε) + inefficiency weight * LN(MAX(1 - path efficiency, ε) + ε)
Calculation: gravity = EMA(raw gravity, gravity smoothing window)
Calculation: gravity change = CHANGE(gravity)
Calculation: warmed up = robust z(gravity), robust z(effort), robust z(displacement) and robust z(gravity change) are all defined
Long: warmed up AND HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > high efficiency AND path efficiency > path efficiency[1] AND signed net log move > 0
Short: warmed up AND HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > high efficiency AND path efficiency > path efficiency[1] AND signed net log move < 0
Long: warmed up AND robust z(displacement) > high z AND robust z(effort) < low z AND path efficiency > high efficiency AND NOT (HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > path efficiency[1]) AND signed net log move > 0
Short: warmed up AND robust z(displacement) > high z AND robust z(effort) < low z AND path efficiency > high efficiency AND NOT (HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > path efficiency[1]) AND signed net log move < 0
Long: warmed up AND robust z(effort) > high z AND robust z(displacement) > high z AND path efficiency > high efficiency AND NOT (HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > path efficiency[1]) AND signed net log move > 0
Short: warmed up AND robust z(effort) > high z AND robust z(displacement) > high z AND path efficiency > high efficiency AND NOT (HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > path efficiency[1]) AND signed net log move < 0
Long: warmed up AND ABS(signed net log move) > directional fraction * expected move AND robust z(gravity change) > slope z AND path efficiency < high efficiency AND NOT (robust z(effort) > high z AND robust z(displacement) < low z AND path efficiency < low efficiency) AND signed net log move > 0
Short: warmed up AND ABS(signed net log move) > directional fraction * expected move AND robust z(gravity change) > slope z AND path efficiency < high efficiency AND NOT (robust z(effort) > high z AND robust z(displacement) < low z AND path efficiency < low efficiency) AND signed net log move < 0
Long: warmed up AND robust z(displacement) > high z AND robust z(gravity) < low z AND path efficiency > high efficiency AND robust z(effort) >= low z AND robust z(effort) <= high z AND NOT (HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > path efficiency[1]) AND signed net log move > 0
Short: warmed up AND robust z(displacement) > high z AND robust z(gravity) < low z AND path efficiency > high efficiency AND robust z(effort) >= low z AND robust z(effort) <= high z AND NOT (HIGHEST(robust z(gravity)[1], release lookback) > high z AND robust z(gravity change) < -slope z AND path efficiency > path efficiency[1]) AND signed net log move < 0
Long: path efficiency > high efficiency AND signed net log move > 0
Short: path efficiency > high efficiency AND signed net log move < 0