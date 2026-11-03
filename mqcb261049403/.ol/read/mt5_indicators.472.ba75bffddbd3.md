Calculation: Pivot Point = (previous completed daily bar high + low + close) / 3; daily bars are higher timeframe than the chart
Calculation: RES2 = Pivot Point + (previous completed daily bar high - low)
Calculation: RES3 = 2 * Pivot Point + previous completed daily bar high - 2 * previous completed daily bar low
Calculation: SUP2 = Pivot Point - (previous completed daily bar high - low)
Calculation: SUP3 = 2 * Pivot Point - (2 * previous completed daily bar high - previous completed daily bar low)
Long: current day's open > Pivot Point
Short: current day's open < Pivot Point
Exit: long, chart bar high >= RES2 OR chart bar high >= RES3
Exit: short, chart bar low <= SUP2 OR chart bar low <= SUP3