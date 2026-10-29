Calculation: Upper Keltner channel band = EMA(close, lookback) + RMA(true range, same lookback)
Calculation: Lower Keltner channel band = EMA(close, lookback) - RMA(true range, same lookback)
Long: flat AND fast EMA (shorter lookback than the channel EMA) > upper Keltner channel band AND previous fast EMA <= previous upper Keltner channel band
Short: flat AND fast EMA (shorter lookback than the channel EMA) < lower Keltner channel band AND previous fast EMA >= previous lower Keltner channel band
Exit: long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance
Exit: short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance