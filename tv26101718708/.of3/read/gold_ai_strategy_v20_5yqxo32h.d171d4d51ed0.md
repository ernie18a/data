Calculation: Fast EMA = EMA(close, shortest lookback)
Calculation: Slow EMA = EMA(close, intermediate lookback)
Calculation: Trend EMA = EMA(close, longest lookback)
Calculation: RSI = RSI(close, lookback)
Calculation: MACD line and signal = MACD(close, fast lookback, slow lookback, signal lookback)
Calculation: Bollinger middle = Bollinger Bands middle(close, lookback)
Calculation: Smoothed stochastic %K = SMA(Stochastic(close, high, low, lookback), smoothing lookback)
Calculation: Stochastic signal = SMA(smoothed stochastic %K, signal lookback)
Calculation: ATR = ATR(high, low, close, lookback)
Calculation: Volume average = SMA(volume, lookback)
Calculation: Long score = count of true conditions: close > Trend EMA; Fast EMA > Slow EMA; RSI > RSI midpoint parameter AND RSI < RSI overbought parameter; MACD line > MACD signal; close > Bollinger middle; smoothed stochastic %K > Stochastic signal AND smoothed stochastic %K < stochastic upper score threshold parameter
Calculation: Short score = count of true conditions: close < Trend EMA; Fast EMA < Slow EMA; RSI < RSI midpoint parameter AND RSI > RSI oversold parameter; MACD line < MACD signal; close < Bollinger middle; smoothed stochastic %K < Stochastic signal AND smoothed stochastic %K > stochastic lower score threshold parameter
Calculation: Trailing distance = ATR at entry × trailing percentage parameter × trailing scale parameter
Long: close > Trend EMA AND Fast EMA > Slow EMA
Short: close < Trend EMA AND Fast EMA < Slow EMA
Long: MACD line > MACD signal
Short: MACD line <= MACD signal
Long: RSI < RSI oversold parameter
Short: RSI > RSI overbought parameter
Long: smoothed stochastic %K < stochastic lower level parameter
Short: smoothed stochastic %K > stochastic upper level parameter
Long: Long score >= score threshold parameter
Short: Short score >= score threshold parameter
Long: Long score >= score threshold parameter AND close > Trend EMA AND (session filter disabled OR datetime is within either configured session) AND (volume filter disabled OR volume > Volume average × volume threshold parameter) AND (Fast EMA crosses above Slow EMA OR MACD line crosses above MACD signal OR RSI crosses above RSI oversold parameter + RSI bounce offset parameter OR smoothed stochastic %K crosses above Stochastic signal AND smoothed stochastic %K < stochastic bullish crossover threshold parameter)
Short: Short score >= score threshold parameter AND close < Trend EMA AND (session filter disabled OR datetime is within either configured session) AND (volume filter disabled OR volume > Volume average × volume threshold parameter) AND (Fast EMA crosses below Slow EMA OR MACD line crosses below MACD signal OR RSI crosses below RSI overbought parameter - RSI bounce offset parameter OR smoothed stochastic %K crosses below Stochastic signal AND smoothed stochastic %K > stochastic bearish crossover threshold parameter)
Exit: Long, low <= entry price - ATR at entry × stop-distance parameter OR high >= entry price + ATR at entry × target-distance parameter OR trailing stop is enabled AND high reaches entry price + Trailing distance AND low <= highest high since activation - Trailing distance
Exit: Short, high >= entry price + ATR at entry × stop-distance parameter OR low <= entry price - ATR at entry × target-distance parameter OR trailing stop is enabled AND low reaches entry price - Trailing distance AND high >= lowest low since activation + Trailing distance