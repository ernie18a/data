Calculation: Volume spike = volume > SMA(volume, volume average lookback) * volume spike multiplier
Calculation: Strong body = ABS(close - open) > (high - low) * strong body ratio
Calculation: Pump candle = close[1] < open[1] AND close > open AND close > open[1] AND open <= close[1] AND Volume spike AND RSI(close, RSI lookback) < RSI overbought level
Calculation: Dump candle = close[1] > open[1] AND close < open AND close < open[1] AND open >= close[1] AND Volume spike AND RSI(close, RSI lookback) > RSI oversold level
Calculation: Momentum pump = close > open AND close - open > ATR(ATR lookback) * momentum ATR multiplier AND Volume spike AND close > EMA(close, shorter EMA lookback) AND close > EMA(close, middle EMA lookback)
Calculation: Momentum dump = close < open AND open - close > ATR(ATR lookback) * momentum ATR multiplier AND Volume spike AND close < EMA(close, shorter EMA lookback) AND close < EMA(close, middle EMA lookback)
Calculation: Bullish trend = EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback)
Calculation: Bearish trend = EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback)
Calculation: Strong pump = Pump candle AND Bullish trend AND MACD histogram(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback) > 0 AND CMF(close, high, low, volume, CMF lookback) > 0 AND Stochastic %K(high, low, close, stochastic lookback) > Stochastic %D(high, low, close, stochastic lookback, %D smoothing lookback) AND Strong body
Calculation: Strong dump = Dump candle AND Bearish trend AND MACD histogram(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback) < 0 AND CMF(close, high, low, volume, CMF lookback) < 0 AND Stochastic %K(high, low, close, stochastic lookback) < Stochastic %D(high, low, close, stochastic lookback, %D smoothing lookback) AND Strong body
Calculation: Pump marking = Pump candle AND NOT Strong pump AND NOT Momentum pump
Calculation: Dump marking = Dump candle AND NOT Strong dump AND NOT Momentum dump
Calculation: Nearest support = highest value below close among the latest maximum zones per side of Pivot low(low, pivot left bars, pivot right bars)
Calculation: Approaching support = close < Nearest support + ATR(ATR lookback) * proximity ATR multiple
Calculation: Nearest resistance = lowest value above close among the latest maximum zones per side of Pivot high(high, pivot left bars, pivot right bars)
Calculation: Approaching resistance = close > Nearest resistance - ATR(ATR lookback) * proximity ATR multiple
Calculation: Fibonacci level(ratio) = IF close > (Highest(high, swing lookback) + Lowest(low, swing lookback)) / 2 THEN Highest(high, swing lookback) - (Highest(high, swing lookback) - Lowest(low, swing lookback)) * ratio ELSE Lowest(low, swing lookback) + (Highest(high, swing lookback) - Lowest(low, swing lookback)) * ratio
Long: Bullish trend
Long: Bullish trend AND close > EMA(close, shorter EMA lookback)
Short: Bearish trend
Short: Bearish trend AND close < EMA(close, shorter EMA lookback)
Long: Pump marking
Long: Strong pump
Long: Momentum pump AND NOT Strong pump
Short: Dump marking
Short: Strong dump
Short: Momentum dump AND NOT Strong dump
Long: Pump candle
Short: Dump candle
Long: Momentum pump
Short: Momentum dump
Long: Approaching support
Short: Approaching resistance
Long: Pump marking AND Approaching support AND Bullish trend
Short: Dump marking AND Approaching resistance AND Bearish trend
Long: ABS(close - Fibonacci level(shallower Fibonacci ratio)) < ATR(ATR lookback) * proximity ATR multiple
Long: ABS(close - Fibonacci level(deeper Fibonacci ratio)) < ATR(ATR lookback) * proximity ATR multiple
Short: ABS(close - Fibonacci level(deeper Fibonacci ratio)) < ATR(ATR lookback) * proximity ATR multiple
Long: MACD histogram(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback) > 0
Short: MACD histogram(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback) <= 0
Long: CMF(close, high, low, volume, CMF lookback) > 0
Short: CMF(close, high, low, volume, CMF lookback) <= 0
Long: Stochastic %K(high, low, close, stochastic lookback) > Stochastic %D(high, low, close, stochastic lookback, %D smoothing lookback)
Short: Stochastic %K(high, low, close, stochastic lookback) <= Stochastic %D(high, low, close, stochastic lookback, %D smoothing lookback)