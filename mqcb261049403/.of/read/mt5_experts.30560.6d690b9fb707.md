Calculation: Center = close of the last completed higher-timeframe bar at the selected weekday and hour
Calculation: Range = configured percentage of ATR from the last completed higher-timeframe bar; if unavailable, configured percentage of current price
Calculation: Profit distance = configured percentage of Range, or prior-loss compensation when nonzero
Calculation: Loss distance = configured percentage of Range plus prior-loss compensation
Long: selected weekday/hour setup is active AND no position is open AND high > Center + Range
Short: selected weekday/hour setup is active AND no position is open AND low < Center - Range
Exit: Long, high >= Center + Range + Profit distance OR low <= Center + Range - Loss distance
Exit: Short, low <= Center - Range - Profit distance OR high >= Center - Range + Loss distance