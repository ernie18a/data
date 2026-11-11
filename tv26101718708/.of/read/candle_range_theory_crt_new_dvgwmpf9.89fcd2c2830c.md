Calculation: Range high and range low = high and low of the last completed higher-timeframe bar, updated when a new higher-timeframe bar begins.
Calculation: Recent inside = at least one of the preceding lookback chart bars has a close greater than or equal to range low and less than or equal to range high, using the current range.
Calculation: High sweep = high > range high AND close <= range high AND recent inside.
Calculation: Low sweep = low < range low AND close >= range low AND recent inside.
Calculation: Sweep direction = reset to none when a new higher-timeframe bar begins; before confirmation on each chart bar, set to high on a high sweep and then set to low on a low sweep, otherwise retain its previous value. Reset confirmation when a new higher-timeframe bar begins; after either entry decision, mark the range confirmed.
Long: range is not confirmed AND sweep direction = low AND low sweep = false AND close > range low.
Short: range is not confirmed AND sweep direction = high AND high sweep = false AND close < range high.