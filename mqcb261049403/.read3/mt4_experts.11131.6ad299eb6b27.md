Calculation: weighted price = (high + low + 2 * close) / 4
Calculation: primary slow moving average = LWMA(weighted price, longer primary MA lookback)
Calculation: entry stochastic %K = Stochastic %K(K lookback, D lookback, slowing, LWMA smoothing, close-close price field)
Calculation: MACD main line = MACD main(weighted price, shorter fast-EMA lookback, longer slow-EMA lookback, signal lookback)
Calculation: long-entry filters = close[0] >= primary slow moving average[1] AND LWMA(weighted price, longer limiter MA lookback)[2] >= LWMA(weighted price, shorter limiter MA lookback)[2] AND Stochastic %K(limiter K lookback, limiter D lookback, limiter slowing, LWMA smoothing, close-close price field)[1] >= Stochastic %D(limiter K lookback, limiter D lookback, limiter slowing, LWMA smoothing, close-close price field)[1] AND Stochastic %K(limiter K lookback, limiter D lookback, limiter slowing, LWMA smoothing, close-close price field)[2] <= Stochastic %D(limiter K lookback, limiter D lookback, limiter slowing, LWMA smoothing, close-close price field)[2]
Long: close[1] - open[1] > minimum candle body size in pips AND long-entry filters
Long: high[1] > high[2] AND low[1] > low[2] AND close[1] > close[2] AND long-entry filters
Long: high[2] > high[3] AND low[2] > low[3] AND close[2] > close[3] AND long-entry filters
Long: Bollinger upper(weighted price, upper-band lookback, upper-band deviation)[1] - Bollinger lower(weighted price, lower-band lookback, lower-band deviation)[1] > minimum band separation in pips AND long-entry filters
Long: RSI(weighted price, shorter RSI lookback)[1] > RSI(weighted price, longer RSI lookback)[1] AND long-entry filters
Long: volume[1] > volume[2] AND volume[1] > minimum volume AND long-entry filters
Long: MACD main line[1] > MACD signal(weighted price, shorter fast-EMA lookback, longer slow-EMA lookback, signal lookback)[1] AND MACD main line[1] > MACD main line[2] AND long-entry filters
Long: entry stochastic %K[1] - entry stochastic %K[2] > stochastic K-change threshold AND long-entry filters
Long: LWMA(weighted price, shorter primary MA lookback)[1] > primary slow moving average[1] AND long-entry filters
Long: entry stochastic %K[1] > Stochastic %D(K lookback, D lookback, slowing, LWMA smoothing, close-close price field)[1] AND entry stochastic %K[1] < stochastic oversold level AND long-entry filters
Exit: long, close[0] != entry price
Exit: short, close[0] != entry price