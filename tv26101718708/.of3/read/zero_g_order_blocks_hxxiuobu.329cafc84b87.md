Calculation: Swing state = 0 if high[n] > Highest(high, n), otherwise 1 if low[n] < Lowest(low, n), otherwise its previous value; initialized at 0
Calculation: Bullish-zone boundaries at detection = bottom low[n], top (high[n] + low[n]) / 2
Calculation: Bearish-zone boundaries at detection = bottom (high[n] + low[n]) / 2, top high[n]
Long: On a chart bar, nonzero confirmed PivotHigh(volume, n, n) AND Swing state = 1, where n is the volume-pivot length
Short: On a chart bar, nonzero confirmed PivotHigh(volume, n, n) AND Swing state = 0, where n is the volume-pivot length
Long: The first subsequent chart bar whose range overlaps a surviving bullish zone: low <= zone top AND high >= zone bottom
Short: The first subsequent chart bar whose range overlaps a surviving bearish zone: low <= zone top AND high >= zone bottom
Exit: Long, any bullish block, existing or detected on this bar, has Lowest(mitigation source, n) < zone bottom; mitigation source is low or close as selected by the mitigation-method parameter
Exit: Short, any bearish block, existing or detected on this bar, has Highest(mitigation source, n) > zone top; mitigation source is low or close as selected by the mitigation-method parameter