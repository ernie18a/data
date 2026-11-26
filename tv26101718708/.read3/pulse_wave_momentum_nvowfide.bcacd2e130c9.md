Calculation: RSI value = SMA(RSI(close, RSI lookback), RSI smoothing length)
Calculation: RSI rising = RSI value > RSI value[1] > ... > RSI value[RSI rise lookback]
Calculation: MACD histogram expanding = ABS(MACD histogram) > ABS(MACD histogram[1]) > ... > ABS(MACD histogram[histogram expansion lookback])
Calculation: ADX rising = ADX > ADX[1] > ... > ADX[ADX rise lookback]
Calculation: ROC rising = ROC(close, ROC lookback) > ROC(close, ROC lookback)[1] > ... > ROC(close, ROC lookback)[ROC rise lookback]
Calculation: Smoothed momentum score = EMA(bull votes - bear votes, score smoothing length), where RSI value is as defined above; MACD line, signal line, and histogram = MACD(close, MACD fast length, MACD slow length, MACD signal length); +DI, -DI, and ADX = DMI(DMI length, DMI length); RSI rising, MACD histogram expanding, ADX rising, and ROC rising are as defined above; base bull votes = (RSI rising AND RSI value > RSI midpoint ? RSI vote weight : 0) + (MACD histogram > 0 AND MACD histogram expanding ? MACD histogram vote weight : MACD line crosses above MACD signal line ? MACD cross vote weight : 0) + (ADX > ADX trend threshold AND ADX rising AND +DI > -DI ? DMI vote weight : 0) + (ROC rising AND ROC(close, ROC lookback) > 0 ? ROC vote weight : 0); base bear votes = (NOT RSI rising AND RSI value < RSI midpoint ? RSI vote weight : 0) + (MACD histogram < 0 AND MACD histogram expanding ? MACD histogram vote weight : 0) + (ADX > ADX trend threshold AND ADX rising AND +DI <= -DI ? DMI vote weight : 0) + (NOT ROC rising AND ROC(close, ROC lookback) < 0 ? ROC vote weight : 0); volume surge = volume > SMA(volume, volume average length) * volume surge multiple; bull votes = base bull votes + (volume surge AND base bull votes > base bear votes ? volume bonus weight : 0); bear votes = base bear votes + (volume surge AND base bear votes > base bull votes ? volume bonus weight : 0)
Long: RSI rising
Short: NOT RSI rising
Long: MACD histogram > 0
Short: MACD histogram <= 0
Long: ROC(close, ROC lookback) > 0
Short: ROC(close, ROC lookback) <= 0
Long: +DI > -DI
Short: +DI <= -DI
Long: Smoothed momentum score > 0
Short: Smoothed momentum score < 0
Long: Smoothed momentum score >= building threshold AND Smoothed momentum score[1] < building threshold
Short: Smoothed momentum score <= fading threshold AND Smoothed momentum score[1] > fading threshold
Long: On confirmation of a pivot low in Smoothed momentum score using pivot left and right lookbacks, its value is higher than the previous confirmed pivot low, the corresponding price low is lower than at the previous pivot, and the pivots are separated by at least the minimum and at most the maximum pivot gap
Short: On confirmation of a pivot high in Smoothed momentum score using pivot left and right lookbacks, its value is lower than the previous confirmed pivot high, the corresponding price high is higher than at the previous pivot, and the pivots are separated by at least the minimum and at most the maximum pivot gap