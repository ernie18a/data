Calculation: RSI/MACD state = long when RSI(close, RSI lookback) > upper RSI threshold AND MACD line(close, shorter lookback, longer lookback) > SMA(MACD line, signal lookback); short when RSI(close, RSI lookback) < lower RSI threshold AND MACD line < SMA(MACD line, signal lookback); otherwise the previous state, with the shorter MACD lookback less than the longer one
Long: RSI/MACD state = long AND RSI/MACD state[1] = short
Short: RSI/MACD state = short AND RSI/MACD state[1] = long
Calculation: TKE composite = arithmetic mean of Ultimate Oscillator(shorter lookback, middle lookback, longer lookback), RSI(positive typical-price volume sum, negative typical-price volume sum), 100 * close / close[component lookback], CCI(typical price, component lookback), RSI(close, component lookback), Williams %R(high, low, close, component lookback), and Stochastic(close, high, low, component lookback); positive and negative typical-price volume sums are SUM(volume * typical price when typical price rises, component lookback) and SUM(volume * typical price when typical price falls, component lookback), and the Ultimate Oscillator lookbacks are ordered shorter than middle than longer
Short: TKE composite crosses below overbought threshold
Long: TKE composite crosses above zero
Calculation: Volume-price envelope source = IF(D > 0, high + D, low + D), where D = (V - SMA(V, volume smoothing lookback)) / STDEV(V - SMA(V, volume smoothing lookback), window lookback) * STDEV(high - low, window lookback), V = S + cumulative_sum(S), and S = (close - open) * volume / (high - low)
Calculation: Volume-price signal = SMA(Volume-price envelope source, signal smoothing lookback)
Long: Volume-price signal crosses above SMA(close, envelope lookback) - ATR(envelope lookback) * envelope multiplier
Short: Volume-price signal crosses below SMA(close, envelope lookback) + ATR(envelope lookback) * envelope multiplier
Long: prior bar range > ATR(extreme-reversal lookback) * extreme-reversal range multiplier AND extreme-reversal minimum body fraction <= abs(close[1] - open[1]) / (high[1] - low[1]) <= extreme-reversal maximum body fraction AND close[1] < open[1] AND close > open
Short: prior bar range > ATR(extreme-reversal lookback) * extreme-reversal range multiplier AND extreme-reversal minimum body fraction <= abs(close[1] - open[1]) / (high[1] - low[1]) <= extreme-reversal maximum body fraction AND close[1] > open[1] AND close < open
Long: prior bar range > ATR(outside-reversal lookback) * outside-reversal range multiplier AND low < low[1] AND close > high[1]
Short: prior bar range > ATR(outside-reversal lookback) * outside-reversal range multiplier AND high > high[1] AND close < low[1]
Long: close > EMA(high, GRaB lookback)
Short: close < EMA(low, GRaB lookback)
Calculation: Hull trend value = HMA(close, Hull lookback), EHMA(close, Hull lookback), or THMA(close, half Hull lookback), according to the selected variant
Long: Hull trend value > Hull trend value[2]
Short: Hull trend value <= Hull trend value[2]