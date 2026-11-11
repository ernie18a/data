Calculation: Range-normalized values = close location value ((close - low) - (high - close)) / (high - low) and body share (close - open) / (high - low); both are zero when high = low.
Calculation: Volume pulse = volume / EMA(volume); division by zero returns zero. The EMA uses the pressure lookback.
Calculation: Pressure strength = clamp(155 * composite / (1 + abs(composite)), -100, 100), where composite = 0.72 * EMA(close location value * volume) / EMA(volume) + 0.28 * EMA(body share * min(volume pulse, 3)); division by zero returns zero and all EMAs use the pressure lookback.
Calculation: Basis = ALMA(price source) * ALMA share + EMA(price source) * (1 - ALMA share); the ALMA and EMA use the same basis lookback.
Calculation: Inner cloud distance = 0.38 * ATR * cloud multiplier * (1 + 0.70 * abs(pressure strength) / 100 + 0.12 * clamp(volume pulse - 1, 0, 2)).
Long: Pressure strength >= 0
Short: Pressure strength < 0
Long: Pressure strength > signal level
Short: Pressure strength < -signal level
Long: Pressure strength crosses above signal level AND close > basis
Short: Pressure strength crosses below -signal level AND close < basis
Long: Pressure strength > signal level AND low <= basis + inner cloud distance AND close > basis AND the same three conditions were not all true on the previous bar
Short: Pressure strength < -signal level AND high >= basis - inner cloud distance AND close < basis AND the same three conditions were not all true on the previous bar