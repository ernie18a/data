Calculation: MFI green = (high - low) / volume is greater than the prior bar’s (high - low) / volume AND volume is greater than the prior bar’s volume
Long: EMA(close, shorter lookback) > EMA(open, medium lookback) AND EMA(open, medium lookback) > WMA(close, longer lookback) AND WMA(ADX, longer lookback) > threshold AND ADX < the same threshold AND MFI green occurred within a short lookback
Long: MACD line > MACD signal line AND OBV > EMA(OBV, medium lookback) AND EMA(hlc3, shorter lookback) > EMA(close, longer lookback) AND Parabolic SAR < low
Short: EMA(close, shorter lookback) < EMA(open, medium lookback) AND EMA(open, medium lookback) < WMA(close, longer lookback) AND WMA(ADX, longer lookback) > threshold AND ADX < the same threshold AND MFI green occurred within a short lookback
Short: MACD line < MACD signal line AND OBV < EMA(OBV, medium lookback) AND EMA(hlc3, shorter lookback) < EMA(close, longer lookback) AND Parabolic SAR > high
Exit: Long, high >= entry price + profit target distance OR low <= entry price - stop-loss distance
Exit: Short, low <= entry price - profit target distance OR high >= entry price + stop-loss distance