Calculation: MACD state = sign(MACD line - EMA(MACD line, signal lookback)), where MACD line = MACD(close, shorter lookback, longer lookback)
Calculation: KDJ state = sign(K - D), where K = SMA(Stochastic %K(high, low, close, KDJ lookback), K smoothing) and D = SMA(K, D smoothing)
Calculation: RSI state = sign(RSI(close, RSI lookback) - RSI midline) if RSI oversold < RSI(close, RSI lookback) < RSI overbought, else 0
Calculation: CCI state = sign(CCI((high + low + close) / 3, CCI lookback) - CCI midline) if CCI oversold < CCI((high + low + close) / 3, CCI lookback) < CCI overbought, else 0
Calculation: VWAP = sum(VWAP source * volume) / sum(volume), both summed from the first chart bar of each T1 period through the current bar
Calculation: VWAP state = sign(close - VWAP)
Calculation: MA = MA(MA source, MA lookback, MA type)
Calculation: MA state = +1 if close > MA AND MA > MA[slope lag], else -1 if close < MA AND MA <= MA[slope lag], else 0
Calculation: volume state = sign(close - open) if volume >= min(mid multiplier, whale multiplier, climax multiplier) * SMA(volume, volume lookback), else 0
Calculation: BB state = +1 if BB %B > BB upper level, else -1 if BB %B < BB lower level, else 0, where BB %B = Bollinger %B(close, BB lookback, BB deviation)
Calculation: Bull% = 100 * (MACD weight * [MACD state = +1] + KDJ weight * [KDJ state = +1] + RSI weight * [RSI state = +1] + CCI weight * [CCI state = +1] + VWAP weight * [VWAP state = +1] + MA weight * [MA state = +1] + volume weight * [volume state = +1] + BB score switch * BB weight * [BB state = +1]) / (MACD weight + KDJ weight + RSI weight + CCI weight + VWAP weight + MA weight + volume weight + BB score switch * BB weight)
Calculation: Bear% = 100 * (MACD weight * [MACD state = -1] + KDJ weight * [KDJ state = -1] + RSI weight * [RSI state = -1] + CCI weight * [CCI state = -1] + VWAP weight * [VWAP state = -1] + MA weight * [MA state = -1] + volume weight * [volume state = -1] + BB score switch * BB weight * [BB state = -1]) / (MACD weight + KDJ weight + RSI weight + CCI weight + VWAP weight + MA weight + volume weight + BB score switch * BB weight)
Calculation: Long trigger = Bull% >= long threshold AND Bull%[1] < long threshold AND (NOT wait-for-close switch OR bar is closed) AND (NOT MA filter switch OR close > MA) AND Last trigger side[1] != Long
Calculation: Short trigger = Bear% >= short threshold AND Bear%[1] < short threshold AND (NOT wait-for-close switch OR bar is closed) AND (NOT MA filter switch OR close < MA) AND Last trigger side[1] != Short
Calculation: Last trigger side = Long if Long trigger, else Short if Short trigger, else Last trigger side[1]
Calculation: ATR trail = low - ATR(ATR lookback) * ATR multiplier if Long trigger, else high + ATR(ATR lookback) * ATR multiplier if Short trigger, else max(ATR trail[1], low - ATR(ATR lookback) * ATR multiplier) if Last trigger side is Long, else min(ATR trail[1], high + ATR(ATR lookback) * ATR multiplier) if Last trigger side is Short, else undefined
Calculation: Gate line = VWAP, ATR trail, or SMA(close, BB lookback), per gate reference
Long: Long trigger AND (NOT gate switch OR Gate line is undefined OR close > Gate line)
Short: Short trigger AND (NOT gate switch OR Gate line is undefined OR close < Gate line)