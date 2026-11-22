Calculation: Volatility = ATR(ATR lookback)
Calculation: Volume factor = min(volume cap, volume / SMA(volume, core lookback)) if SMA(volume, core lookback) > 0, else min(volume cap, 1)
Calculation: Flow = min(1, max(-1, EMA((close - close[1]) / Volatility * Volume factor, smoothing length)))
Calculation: Displacement = min(1, max(-1, (close - open) / Volatility * Volume factor / displacement scale))
Calculation: Structure = 2 * position - 1, where position = (close - lowest(low, core lookback)) / (highest(high, core lookback) - lowest(low, core lookback)), and position = 0 if highest(high, core lookback) - lowest(low, core lookback) is zero
Calculation: Participation = EMA(50 + 50 * min(1, max(-1, flow weight * Flow + displacement weight * Displacement + structure weight * Structure)), smoothing length)
Long: bar is closed AND Participation >= signal threshold AND Participation[1] < signal threshold AND position side on previous bar is flat
Long: Participation >= signal threshold
Long: Participation > lean upper level
Short: bar is closed AND Participation <= 100 - signal threshold AND Participation[1] > 100 - signal threshold AND position side on previous bar is flat
Short: Participation <= 100 - signal threshold
Short: Participation < lean lower level
Exit: long, bar after entry bar AND (low <= entry price - stop multiplier * Volatility at entry bar OR high >= entry price + TP3 multiplier * Volatility at entry bar)
Exit: short, bar after entry bar AND (high >= entry price + stop multiplier * Volatility at entry bar OR low <= entry price - TP3 multiplier * Volatility at entry bar)