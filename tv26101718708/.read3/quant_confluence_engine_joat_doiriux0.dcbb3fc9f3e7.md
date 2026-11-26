Calculation: trend vote = sign(EMA(close, shorter EMA lookback) - EMA(close, longer EMA lookback))
Calculation: momentum vote = sign(RSI(close, RSI lookback) - RSI midline)
Calculation: MACD vote = sign(MACD histogram(close, shorter MACD lookback, longer MACD lookback, MACD signal lookback))
Calculation: strength vote = sign(plus DI(high, low, close, ADX lookback) - minus DI(high, low, close, ADX lookback)) if ADX(high, low, close, ADX lookback) >= ADX threshold, else 0
Calculation: volume vote = sign(close - open) if volume / SMA(volume, volume lookback) >= relative volume threshold, else 0
Calculation: location vote = 1 if (close - lowest(low, location lookback)) / (highest(high, location lookback) - lowest(low, location lookback)) <= lower location threshold, -1 if (close - lowest(low, location lookback)) / (highest(high, location lookback) - lowest(low, location lookback)) >= upper location threshold, else 0
Calculation: composite score = 100 * (trend weight * trend vote + momentum weight * momentum vote + MACD weight * MACD vote + strength weight * strength vote + volume weight * volume vote + location weight * location vote) / (trend weight + momentum weight + MACD weight + strength weight + volume weight + location weight)
Calculation: bullish signal = EMA(composite score, smoothing lookback) >= score threshold AND count of the six votes above 0 >= minimum agreeing factors
Calculation: bearish signal = EMA(composite score, smoothing lookback) <= -score threshold AND count of the six votes below 0 >= minimum agreeing factors
Calculation: signal state = 1 if bullish signal, -1 if bearish signal, else signal state[1], initially 0
Calculation: stop distance = ATR(high, low, close, ATR lookback) * stop multiple, fixed at the entry bar
Long: bullish signal AND signal state[1] <= 0
Long: signal state = 1
Long: EMA(composite score, smoothing lookback) >= 0
Long: EMA(composite score, smoothing lookback) crosses above 0
Short: bearish signal AND signal state[1] >= 0
Short: signal state = -1
Short: EMA(composite score, smoothing lookback) < 0
Short: EMA(composite score, smoothing lookback) crosses below 0
Exit: long, high >= entry price + stop distance * TP1 multiple OR low <= entry price - stop distance
Exit: short, low <= entry price - stop distance * TP1 multiple OR high >= entry price + stop distance