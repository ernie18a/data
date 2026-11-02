Calculation: Period POC = For each selected period, collect chart-bar typical prices (high + low + close) / 3 and nonnegative volumes. Divide the range from the minimum to maximum collected price into equal-width rows; add each bar’s entire volume to the row containing its typical price, clamping the maximum price to the last row. Return the midpoint of the row with the greatest volume, choosing the lowest row on a tie; if all prices are equal, return that price. Use the last completed period. Calculate three POCs using shorter, intermediate, and longer periods; the selected active POC is one of these. Each period may be higher, equal to, or lower than the chart timeframe.
Calculation: VWAP gate = Volume-weighted mean of chart-bar typical price over the last completed selected period, using nonnegative volume. Its period may be higher, equal to, or lower than the chart timeframe.
Calculation: VWAP deviation = Square root of the nonnegative volume-weighted variance of chart-bar typical price over the VWAP gate’s last completed period. Upper and lower gates equal the VWAP gate plus and minus a selected multiplier times this deviation.
Calculation: Control count = Number of the three period POCs and the VWAP gate that the close is strictly above; unavailable levels contribute zero.
Calculation: Near control = Absolute percentage distance from close to any of the three POCs, VWAP gate, upper gate, or lower gate is at or below the selected threshold; ignore unavailable or zero levels.
Long: Close > any period POC OR close > VWAP gate
Short: Close <= any available period POC OR close <= VWAP gate
Long: Control count >= 3 AND near control is false
Short: Control count <= 1 AND near control is false
Long: Close crosses above VWAP gate AND (volume confirmation is disabled OR volume / its simple moving average >= the selected threshold)
Short: Close crosses below VWAP gate
Long: Low <= lower gate AND close > lower gate AND close > open
Short: High >= upper gate AND close < upper gate AND close < open
Long: Close > upper gate AND previous close <= current upper gate
Short: Close < lower gate AND previous close >= current lower gate
Long: Close crosses above active POC
Short: Close crosses below active POC