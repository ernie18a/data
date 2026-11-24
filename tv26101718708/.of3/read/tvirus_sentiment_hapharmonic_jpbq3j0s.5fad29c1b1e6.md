Calculation: RSI group = 5 if RSI(close, RSI length) < RSI lower-extreme threshold; else 4 if RSI(close, RSI length) < RSI lower threshold; else 1 if RSI(close, RSI length) > RSI upper-extreme threshold; else 2 if RSI(close, RSI length) > RSI upper threshold; else 3
Calculation: EMA group = 1 if EMA(close, EMA length 1) < EMA(close, EMA length 2) < EMA(close, EMA length 3) < EMA(close, EMA length 4) < EMA(close, EMA length 5) < EMA(close, EMA length 6); else 2 if EMA(close, EMA length 1) > EMA(close, EMA length 2) AND EMA(close, EMA length 2) < EMA(close, EMA length 3); else 5 if EMA(close, EMA length 1) > EMA(close, EMA length 2) > EMA(close, EMA length 3) > EMA(close, EMA length 4) > EMA(close, EMA length 5) > EMA(close, EMA length 6); else 4 if EMA(close, EMA length 1) > EMA(close, EMA length 2) > EMA(close, EMA length 3) > EMA(close, EMA length 4); else 3, where EMA length 1 < EMA length 2 < EMA length 3 < EMA length 4 < EMA length 5 < EMA length 6
Calculation: MACD line = MA(close, MACD fast length, MACD source MA type) - MA(close, MACD slow length, MACD source MA type), where MACD fast length < MACD slow length
Calculation: MACD signal = MA(MACD line, MACD signal length, MACD signal MA type)
Calculation: MACD histogram = MACD line - MACD signal
Calculation: MACD group = 1 if MACD line < 0 AND MACD histogram < 0 AND falling(MACD histogram, shorter MACD histogram lookback); else 2 if MACD line < 0 AND (MACD histogram >= 0 OR rising(MACD histogram, shorter MACD histogram lookback)); else 5 if MACD line > 0 AND MACD histogram > 0 AND rising(MACD line, longer MACD line lookback) AND rising(MACD histogram, shorter MACD histogram lookback); else 4 if MACD line > 0 AND MACD histogram > 0 AND (MACD line > MACD signal OR rising(MACD histogram, shorter MACD histogram lookback)); else 3
Calculation: plus DI = +DI(ADX length)
Calculation: minus DI = -DI(ADX length)
Calculation: ADX = ADX(ADX length, ADX smoothing)
Calculation: ADX group = 5 if ADX > ADX strong threshold AND plus DI > minus DI; else 4 if ADX >= ADX trend threshold AND plus DI > minus DI; else 2 if ADX >= ADX weak threshold AND ADX < ADX trend threshold AND minus DI - plus DI > DI tolerance; else 1 if ADX < ADX weak threshold AND minus DI > plus DI; else 3
Calculation: Tenkan = (highest(high, conversion length) + lowest(low, conversion length)) / 2, where conversion length < base length < leading span B length
Calculation: Kijun = (highest(high, base length) + lowest(low, base length)) / 2
Calculation: Senkou A = (Tenkan + Kijun) / 2
Calculation: Senkou B = (highest(high, leading span B length) + lowest(low, leading span B length)) / 2
Calculation: cloud top = max(Senkou A[displacement], Senkou B[displacement])
Calculation: cloud bottom = min(Senkou A[displacement], Senkou B[displacement])
Calculation: Ichimoku group = 1 if Tenkan < Kijun AND close < cloud bottom AND close < close[displacement]; else 2 if Tenkan < Kijun AND ((close >= cloud bottom AND close <= cloud top) OR close >= close[displacement]); else 5 if Tenkan > Kijun AND close > cloud top AND close > close[displacement] AND Senkou A > Senkou B AND Senkou A - Senkou B > (Senkou A - Senkou B)[1]; else 4 if Tenkan > Kijun AND close > cloud top AND close > close[displacement]; else 3
Calculation: BB basis = MA(close, BB length, BB MA type)
Calculation: BB upper = BB basis + BB multiplier * stdev(close, BB length)
Calculation: BB lower = BB basis - BB multiplier * stdev(close, BB length)
Calculation: BB group = 1 if close <= BB lower AND (close < BB lower OR falling(BB lower, BB slope lookback) OR falling(BB basis, BB slope lookback)); else 5 if close >= BB upper AND (close > BB upper OR rising(BB upper, BB slope lookback) OR rising(BB basis, BB slope lookback)); else 2 if BB lower <= close < BB basis; else 4 if BB basis < close <= BB upper; else 3
Calculation: OBV = running sum of sign(close - close[1]) * volume
Calculation: OBV MA = MA(OBV, OBV MA length, OBV MA type)
Calculation: OBV group = 1 if OBV < OBV MA AND falling(OBV, OBV fall lookback); else 2 if OBV < OBV MA AND (rising(OBV, shorter OBV rise lookback) OR OBV >= OBV MA * (1 - OBV near tolerance)); else 3 if abs(OBV - OBV MA) <= abs(OBV MA) * OBV near tolerance; else 4 if OBV > OBV MA AND rising(OBV, shorter OBV rise lookback); else 5 if OBV > OBV MA AND rising(OBV, longer OBV rise lookback) AND OBV - OBV[1] > OBV spike multiplier * SMA(abs(OBV - OBV[1]), OBV spike average length); else 3
Calculation: Sentiment score = round(100 * ((RSI group + EMA group + MACD group + ADX group + Ichimoku group + BB group + OBV group) / 7 - 1) / 4)
Calculation: Buy-side volume = volume * (close - low) / (high - low) if high > low, else volume * 0.5
Calculation: Buy pressure = 100 * (sum of Buy-side volume over the last buy-pressure window bars) / (sum of volume over the last buy-pressure window bars)
Long: Sentiment score > sentiment threshold AND Buy pressure > buy-pressure threshold
Short: Sentiment score <= sentiment threshold OR Buy pressure <= buy-pressure threshold
Long: Buy pressure >= bubble mid threshold
Short: Buy pressure < bubble low threshold
Long: Sentiment score > gauge bullish threshold
Short: Sentiment score <= gauge bearish threshold
Long: RSI group > 3
Short: RSI group < 3
Long: EMA group > 3
Short: EMA group < 3
Long: MACD group > 3
Short: MACD group < 3
Long: ADX group > 3
Short: ADX group < 3
Long: Ichimoku group > 3
Short: Ichimoku group < 3
Long: BB group > 3
Short: BB group < 3
Long: OBV group > 3
Short: OBV group < 3