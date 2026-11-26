Calculation: transformed price source = log(configured price source) when log-space is enabled, otherwise configured price source
Calculation: volume-weighted mean = SUM(volume × transformed price source) / SUM(volume) over the lookback chart bars including the current bar
Calculation: volume-weighted average absolute deviation = SUM(volume × ABS(transformed price source − volume-weighted mean)) / SUM(volume) over the same lookback chart bars including the current bar
Calculation: exit basis = exp(volume-weighted mean) when log-space is enabled, otherwise volume-weighted mean
Calculation: OBV RSI = RSI(OBV(close, volume), RSI lookback)
Long: flat AND close <= volume-weighted mean − band multiplier × volume-weighted average absolute deviation AND OBV RSI <= lower threshold AND OBV RSI < higher threshold AND current bar index > most recent exit bar index + cooldown lookback, with the initial exit bar index set to zero
Short: flat AND close >= volume-weighted mean + band multiplier × volume-weighted average absolute deviation AND OBV RSI >= higher threshold AND current bar index > most recent exit bar index + cooldown lookback, with the initial exit bar index set to zero
Exit: long, close crosses above exit basis OR close < entry price × (1 − stop-loss fraction)
Exit: short, close crosses below exit basis OR close > entry price × (1 + stop-loss fraction)