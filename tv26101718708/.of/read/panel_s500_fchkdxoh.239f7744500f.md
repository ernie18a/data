Calculation: VSA activity = volume > its moving average AND (high - low) > the moving average of (high - low)
Calculation: Smoothed volume delta = moving average of volume when close > open, negative volume when close < open, and zero when close = open
Calculation: Range-to-ATR ratio = (high - low) / ATR
Calculation: Compression ratio = ATR / moving average of ATR
Long: On each requested timeframe, EMA with the shorter lookback > EMA with the longer lookback OR RSI > 50 OR RSI > its previous value OR MACD > 0 OR MACD > its previous value OR ADX > 25
Long: OBV > its previous value OR volume > its moving average OR volume moving average > its previous value OR VSA activity OR Stochastic > 50 OR close > VWAP OR EMA(50) > EMA(200) OR EMA(26) > EMA(50) OR close > EMA(20) OR RSI > its previous value OR EMA(20) > its previous value OR range-to-ATR ratio > 1.1 OR body size / (high - low) > 0.6 OR ATR > its previous value OR smoothed volume delta > 0 OR compression ratio > 1
Long: close > EMA(50) AND EMA(50) > EMA(200) AND close > VWAP
Long: EMA(50) > EMA(200) AND NOT (ABS(EMA(50) - EMA(200)) < ATR * 0.2)
Short: On each requested timeframe, EMA with the shorter lookback <= EMA with the longer lookback OR RSI <= 50 OR RSI < its previous value OR MACD <= 0 OR MACD < its previous value OR ADX < 20
Short: OBV <= its previous value OR volume <= its moving average OR volume moving average <= its previous value OR NOT VSA activity OR Stochastic <= 50 OR close <= VWAP OR EMA(50) <= EMA(200) OR EMA(26) <= EMA(50) OR close <= EMA(20) OR RSI < its previous value OR EMA(20) <= its previous value OR range-to-ATR ratio <= 1.1 OR body size / (high - low) <= 0.6 OR ATR <= its previous value OR smoothed volume delta <= 0 OR compression ratio <= 1
Short: close < EMA(50) AND EMA(50) < EMA(200) AND close < VWAP
Short: EMA(50) < EMA(200) AND NOT (ABS(EMA(50) - EMA(200)) < ATR * 0.2)