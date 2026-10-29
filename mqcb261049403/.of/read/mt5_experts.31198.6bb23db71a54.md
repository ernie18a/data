Calculation: Range = configured fraction of the reference price, configured fraction of ATR(20) on the higher timeframe’s still-forming bar, or configured fixed point distance
Calculation: Breakout levels = setup reference price ± Range × configured range fraction
Calculation: Take-profit distance = Range × configured take-profit fraction, adjusted by the configured range multiplier after a losing trade
Calculation: Stop-loss distance = Range × configured stop-loss fraction
Long: Setup established AND ((high > upper breakout level AND trade mode is Stop) OR (low < lower breakout level AND trade mode is Limit))
Short: Setup established AND ((low < lower breakout level AND trade mode is Stop) OR (high > upper breakout level AND trade mode is Limit))
Exit: Long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance
Exit: Short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance