Calculation: TEMA = 3 × EMA(close, short lookback) − 3 × EMA(EMA(close, short lookback), short lookback) + EMA(EMA(EMA(close, short lookback), short lookback), short lookback)
Calculation: LSMA = linear regression of close over a lookback
Calculation: EMA = exponential moving average of close over a lookback
Calculation: SMA = simple moving average of its input over a lookback
Calculation: ATR = average true range over a lookback
Calculation: Volume average = SMA(volume, lookback)
Calculation: Swing high = highest high over a lookback
Calculation: Swing low = lowest low over a lookback
Calculation: VWAP = volume-weighted average price
Calculation: Zone score = average of percentage differences between close and TEMA, LSMA, and EMA
Calculation: Bullish consensus = at least half of these are true: RSI above 50; stochastic above 50 or above its signal; stochastic RSI above 50; MACD above its signal; Williams %R above −50; CCI above 0
Calculation: Bearish consensus = at least half of these are true: RSI below 50; stochastic below 50 or below its signal; stochastic RSI below 50; MACD below its signal; Williams %R below −50; CCI below 0
Long: close is between the lowest low over a lookback and that low plus ATR times a zone-width parameter
Long: (low is below the last confirmed pivot low AND close is above the prior bar's high AND prior bar's high minus low exceeds ATR times a sweep-size parameter AND close is above EMA) OR (close is within a tolerance of the last bullish EMA crossover level AND close is above open AND TEMA is above LSMA) OR (zone score is below a negative oversold threshold AND close is above EMA AND TEMA is above LSMA)
Long: close is above the short-term KAMA AND KAMA is rising AND (ADX exceeds a threshold OR positive DI exceeds negative DI) AND bullish consensus AND volume exceeds its average times a volume parameter AND active-hours filter is true
Long: (close is above the long-term SMA AND below the short-term SMA AND flat) OR (close is at least a dip threshold below the highest high over a lookback AND flat)
Long: (all of TEMA, LSMA, and EMA are rising OR TEMA is above LSMA AND close is above EMA) AND TEMA crosses above LSMA AND volume exceeds its average times a volume parameter
Short: close is between the highest high over a lookback minus ATR times a zone-width parameter and that highest high
Short: (close is within a tolerance of the last bearish EMA crossover level AND close is below open AND TEMA is below LSMA) OR (high is below the last confirmed pivot high AND above the prior bar's high AND zone score is above an overbought threshold AND TEMA is below LSMA) OR (EMA test count reaches a threshold AND close is below EMA AND TEMA is below LSMA AND close crosses below EMA)
Short: close is below the short-term KAMA AND KAMA is falling AND (ADX exceeds a threshold OR negative DI exceeds positive DI) AND bearish consensus AND volume exceeds its average times a volume parameter AND active-hours filter is true
Short: (all of TEMA, LSMA, and EMA are falling OR TEMA is below LSMA AND close is below EMA) AND TEMA crosses below LSMA AND volume exceeds its average times a volume parameter
Exit: Long, low is at or below entry price minus ATR times a stop parameter OR high is at or above entry price plus ATR times a target parameter OR price reaches the trailing stop at an ATR-based distance OR bars since entry reach a maximum duration
Exit: Short, high is at or above entry price plus ATR times a stop parameter OR low is at or below entry price minus ATR times a target parameter OR price reaches the trailing stop at an ATR-based distance OR bars since entry reach a maximum duration