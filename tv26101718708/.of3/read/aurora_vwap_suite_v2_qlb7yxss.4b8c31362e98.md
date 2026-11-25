Calculation: safe ATR = max(ATR(lookback) if available, otherwise high - low; minimum price increment)
Calculation: alert test tolerance = safe ATR × alert test tolerance multiplier
Calculation: anchor tolerance = safe ATR × anchor tolerance multiplier
Calculation: alert band width = band multiplier × selected distance (VWAP standard deviation, ATR(lookback), or absolute selected VWAP reference / 100)
Calculation: valid signal bar = selected VWAP reference is available on current and previous bars, has not reset on the current bar, and has the same anchor key on both bars (and the same session identity when it is the winner reference), and (close confirmation is disabled OR the current bar is confirmed)
Calculation: VWAP bias = sum of signed votes divided by the count of valid votes; enabled, available T1-reset VWAP, T2-reset VWAP, winner VWAP, and low-anchor and high-anchor VWAPs each vote +1 when close is above them, -1 when below, and 0 when equal; the T1-reset VWAP slope votes +1 when its current value is above its value slope lookback bars ago, -1 when below, and 0 when equal, only when both values belong to the same reset period
Long: close crosses above the selected VWAP reference AND valid signal bar
Long: low >= selected VWAP reference - alert test tolerance AND low <= selected VWAP reference + alert test tolerance AND close > selected VWAP reference + alert test tolerance AND valid signal bar
Long: close crosses above the selected VWAP reference + alert band width AND alert band width is positive on current and previous bars AND valid signal bar
Long: VWAP bias >= bullish bias threshold
Long: low-anchor VWAP is available AND close > low-anchor VWAP + anchor tolerance
Long: high-anchor VWAP is available AND close > high-anchor VWAP + anchor tolerance
Short: close crosses below the selected VWAP reference AND valid signal bar
Short: high >= selected VWAP reference - alert test tolerance AND high <= selected VWAP reference + alert test tolerance AND close < selected VWAP reference - alert test tolerance AND valid signal bar
Short: close crosses below the selected VWAP reference - alert band width AND alert band width is positive on current and previous bars AND valid signal bar
Short: VWAP bias <= bearish bias threshold
Short: low-anchor VWAP is available AND close < low-anchor VWAP - anchor tolerance
Short: high-anchor VWAP is available AND close < high-anchor VWAP - anchor tolerance