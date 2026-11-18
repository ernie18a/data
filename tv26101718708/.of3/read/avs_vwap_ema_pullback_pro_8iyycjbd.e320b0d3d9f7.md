Long: bar open datetime is within the session parameter AND ADX(DMI lookback, ADX smoothing) >= minimum ADX AND close > VWAP(hlc3) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND +DI(DMI lookback) > -DI(DMI lookback) AND low <= VWAP(hlc3) * (1 + pullback percentage / 100) AND close > EMA(close, shorter lookback) AND RSI(close, RSI lookback) > long RSI threshold
Short: bar open datetime is within the session parameter AND ADX(DMI lookback, ADX smoothing) >= minimum ADX AND close < VWAP(hlc3) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND -DI(DMI lookback) > +DI(DMI lookback) AND high >= VWAP(hlc3) * (1 - pullback percentage / 100) AND close < EMA(close, shorter lookback) AND RSI(close, RSI lookback) < short RSI threshold
Calculation: long stop = min(VWAP(hlc3), EMA(close, longer lookback)) - ATR(ATR lookback) * stop ATR multiple, using values at the long signal
Calculation: long risk = close at long signal - long stop
Calculation: long target 1 = close at long signal + long risk * first reward/risk parameter
Calculation: long target 2 = close at long signal + long risk * second reward/risk parameter
Calculation: short stop = max(VWAP(hlc3), EMA(close, longer lookback)) + ATR(ATR lookback) * stop ATR multiple, using values at the short signal
Calculation: short risk = short stop - close at short signal
Calculation: short target 1 = close at short signal - short risk * first reward/risk parameter
Calculation: short target 2 = close at short signal - short risk * second reward/risk parameter
Exit: long, low <= long stop
Exit: long, high >= long target 1
Exit: long, high >= long target 2
Exit: short, high >= short stop
Exit: short, low <= short target 1
Exit: short, low <= short target 2