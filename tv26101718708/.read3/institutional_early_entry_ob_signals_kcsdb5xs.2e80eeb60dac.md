Calculation: Bullish order block = [low, high] of the most recent candle with close < open as of the latest bar where close > highest(high[1], structure lookback), when that break is within the order-block-validity lookback bars and no later bearish break exists
Calculation: Bearish order block = [low, high] of the most recent candle with close > open as of the latest bar where close < lowest(low[1], structure lookback), when that break is within the order-block-validity lookback bars and no later bullish break exists
Calculation: Long EMA trend = close > EMA(close, fast EMA lookback) AND (signal mode is aggressive OR EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback)) AND (signal mode is not conservative OR EMA(close, fast EMA lookback) > EMA(close, fast EMA lookback)[1])
Calculation: Short EMA trend = close < EMA(close, fast EMA lookback) AND (signal mode is aggressive OR EMA(close, fast EMA lookback) < EMA(close, slow EMA lookback)) AND (signal mode is not conservative OR EMA(close, fast EMA lookback) < EMA(close, fast EMA lookback)[1])
Calculation: Volume confirmation = volume confirmation disabled OR volume > SMA(volume, volume lookback) * volume multiplier
Calculation: Stochastic %K = SMA(Stochastic(close, high, low, stochastic lookback), K smoothing)
Calculation: Stochastic %D = SMA(Stochastic %K, D smoothing)
Calculation: Long confirmed setup = low <= bullish order block high AND high >= bullish order block low AND (close > open OR close > (bullish order block high + bullish order block low) / 2) AND long EMA trend AND RSI(close, RSI lookback) > long RSI threshold AND (stochastic confirmation disabled OR Stochastic %K > Stochastic %D OR Stochastic %K > 50) AND volume confirmation
Calculation: Short confirmed setup = high >= bearish order block low AND low <= bearish order block high AND (close < open OR close < (bearish order block high + bearish order block low) / 2) AND short EMA trend AND RSI(close, RSI lookback) < short RSI threshold AND (stochastic confirmation disabled OR Stochastic %K < Stochastic %D OR Stochastic %K < 50) AND volume confirmation
Calculation: Long stop = bullish order block low on the valid long-entry signal bar - ATR(ATR lookback) on that bar * stop buffer
Calculation: Short stop = bearish order block high on the valid short-entry signal bar + ATR(ATR lookback) on that bar * stop buffer
Calculation: Long target = close on the latest valid long-entry signal bar + (that close - long stop) * reward-risk parameter
Calculation: Short target = close on the latest valid short-entry signal bar - (short stop - that close) * reward-risk parameter
Long: early signal enabled AND low <= bullish order block high AND high >= bullish order block low AND long EMA trend AND RSI(close, RSI lookback) > long RSI threshold AND volume confirmation
Long: long confirmed setup AND NOT long confirmed setup[1] AND close - long stop > minimum price increment
Short: early signal enabled AND high >= bearish order block low AND low <= bearish order block high AND short EMA trend AND RSI(close, RSI lookback) < short RSI threshold AND volume confirmation
Short: short confirmed setup AND NOT short confirmed setup[1] AND short stop - close > minimum price increment
Exit: long, exit signal enabled AND (low <= long stop OR high >= long target)
Exit: short, exit signal enabled AND (high >= short stop OR low <= short target)