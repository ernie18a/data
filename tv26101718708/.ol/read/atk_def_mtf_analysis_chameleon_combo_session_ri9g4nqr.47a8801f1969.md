Calculation: MTF ADX, +DI, −DI, RSI, close, high, low, ATR, average ATR, and EMAs = calculate on bars aggregated to a higher timeframe than the chart timeframe, using the current higher-timeframe bar, including while it is still forming. Use short-, intermediate-, and long-period EMAs for the three EMA comparisons.
Calculation: MTF ADX change and MTF RSI change = each value minus its value five higher-timeframe bars earlier.
Calculation: Process score = 100 if ADX change > 5 AND RSI change > 3; otherwise 66 if ADX change > 2 AND RSI change > 1; otherwise 0 if ADX change > −2 AND RSI change > −2; otherwise −66 if ADX change > −5 AND RSI change > −3; otherwise −100.
Calculation: Radar total = clamp(ADX / 100 × 33 + (RSI − 50) / 50 × 33 + clamp((ATR / average ATR − 1) × 34, −34, 34), −100, 100), using the higher-timeframe values.
Calculation: Radar score = 100 if radar total > 60; otherwise 66 if > 30; otherwise 33 if > −10; otherwise −33 if > −40; otherwise −66.
Calculation: Test-depth position = (close − lowest low over the longer lookback) / (highest high over that same lookback − lowest low over that lookback + 0.0001) × 100, using higher-timeframe bars.
Calculation: Test-depth score = 100 if position > 80; otherwise 66 if > 60; otherwise 33 if > 40; otherwise −33 if > 20; otherwise −66.
Calculation: Direction score = 100 if close is above all three EMAs AND +DI > −DI; otherwise 75 if close is above all three EMAs; otherwise −100 if close is below all three EMAs AND −DI > +DI; otherwise −75 if close is below all three EMAs; otherwise 25 if close > shortest EMA AND close < intermediate EMA; otherwise −25 if close < shortest EMA AND close > intermediate EMA; otherwise 0. Use higher-timeframe values.
Calculation: Final score = clamp((process score + radar score + test-depth score + direction score) / 4, −100, 100).
Long: Final score > 15.
Short: Final score ≤ −15.