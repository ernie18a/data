Calculation: VWAP = cumulative(hlc3 * volume) / cumulative(volume), reset at the start of each session
Calculation: BullCount = number of true among [close > VWAP, fast EMA(close) > slow EMA(close), RSI(close) > 50]; fast EMA has a shorter lookback than slow EMA
Calculation: BearCount = number of true among [close <= VWAP, fast EMA(close) <= slow EMA(close), RSI(close) <= 50]
Long: close crosses above VWAP (close > VWAP and previous close <= previous VWAP) OR fast EMA crosses above slow EMA (fast > slow and previous fast <= previous slow) OR (ADX >= strong-trend threshold AND BullCount >= 2)
Short: close crosses below VWAP (close < VWAP and previous close >= previous VWAP) OR fast EMA crosses below slow EMA (fast < slow and previous fast >= previous slow) OR (ADX >= strong-trend threshold AND BearCount >= 2)
Exit: long, high >= entry price + profit-target distance OR low <= entry price - stop-loss distance
Exit: short, low <= entry price - profit-target distance OR high >= entry price + stop-loss distance