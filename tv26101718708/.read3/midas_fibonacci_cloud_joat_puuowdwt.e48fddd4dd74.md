Calculation: TP = (high + low + close) / 3
Calculation: AVWAP = VWAP(TP, volume, anchor) if summed volume since anchor is greater than 0, else TP
Calculation: SD = sqrt(max(0, VWAP(TP^2, volume, anchor) - AVWAP^2)) if summed volume since anchor is greater than 0, else 0
Calculation: UB(m) = AVWAP + SD * sensitivity * m
Calculation: LB(m) = AVWAP - SD * sensitivity * m
Calculation: body = abs(close - open) / (high - low) if high > low, else 0
Calculation: part = min(volume / EMA(volume, volume lookback), volume cap) / volume cap if EMA(volume, volume lookback) > 0, else neutral participation
Calculation: wick = (close > open ? (close - low) : (high - close)) / (high - low) if high > low, else neutral wick
Calculation: OF = body weight * body + participation weight * part + wick weight * wick
Long: close crosses above AVWAP AND OF >= order flow threshold
Short: close crosses below AVWAP AND OF >= order flow threshold
Short: close crosses above UB(outer multiplier)
Long: close crosses below LB(outer multiplier)
Long: close > UB(inner multiplier)
Short: close < LB(inner multiplier)
Long: candle coloring enabled AND SD > 0 AND close > AVWAP
Short: candle coloring enabled AND (SD = 0 OR close <= AVWAP)