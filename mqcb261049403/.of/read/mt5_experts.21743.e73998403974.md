Calculation: MA A and MA B = the same moving average, with configurable smoothing method, applied price, horizontal shift and period, evaluated at two distinct configurable bar offsets A and B. The MA timeframe may be the chart timeframe or a higher or lower timeframe; offset zero uses its still-forming bar, and positive offsets use completed bars.
Long: At the opening of a chart bar, hour >= start hour AND hour < end hour AND ((reverse = off AND MA A > MA B + difference) OR (reverse = on AND MA A <= MA B + difference AND MA A < MA B - difference)).
Short: At the opening of a chart bar, hour >= start hour AND hour < end hour AND ((reverse = off AND MA A <= MA B + difference) OR (reverse = on AND (MA A > MA B + difference OR MA A >= MA B - difference))).
Exit: short, close opposite positions = on AND the Long condition is true.
Exit: long, close opposite positions = on AND the Short condition is true.
Exit: long, stop loss enabled AND low <= entry price - stop distance OR take profit enabled AND high >= entry price + profit distance.
Exit: short, stop loss enabled AND high >= entry price + stop distance OR take profit enabled AND low <= entry price - profit distance.