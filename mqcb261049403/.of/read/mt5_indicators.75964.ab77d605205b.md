Calculation: Range high = highest high of the preceding lookback bars, excluding the current bar.
Calculation: Range low = lowest low of the preceding lookback bars, excluding the current bar.
Calculation: Range span = range high minus range low; if the result is nonpositive, use a small positive fallback.
Calculation: Resistance boundary = range high minus range span multiplied by the zone fraction.
Calculation: Support boundary = range low plus range span multiplied by the zone fraction.
Long: Close > range high.
Short: Close < range low.
Short: Close <= range high AND close >= range low AND close >= resistance boundary.
Long: Close <= range high AND close >= range low AND close < resistance boundary AND close <= support boundary.