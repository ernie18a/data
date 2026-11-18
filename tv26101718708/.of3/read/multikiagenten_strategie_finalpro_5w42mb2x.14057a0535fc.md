Calculation: Short-term EMA = EMA(close, short-term lookback), with short-term lookback < medium-term lookback < long-term lookback
Calculation: Medium-term EMA = EMA(close, medium-term lookback)
Calculation: Long-term EMA = EMA(close, long-term lookback)
Calculation: RSI value = RSI(close, RSI lookback)
Calculation: Average volume = SMA(volume, volume-average lookback)
Calculation: ATR value = ATR(ATR lookback)
Calculation: Upper Fibonacci level = highest(high, Fibonacci lookback) - (highest(high, Fibonacci lookback) - lowest(low, Fibonacci lookback)) * upper retracement ratio
Calculation: Lower Fibonacci level = highest(high, Fibonacci lookback) - (highest(high, Fibonacci lookback) - lowest(low, Fibonacci lookback)) * lower retracement ratio, with upper retracement ratio > lower retracement ratio
Calculation: Long score = (trend weight if short-term EMA > medium-term EMA AND medium-term EMA > long-term EMA AND close > short-term EMA, otherwise 0) + (economic weight if RSI value < oversold threshold, otherwise 0) + (volume weight if volume > Average volume * volume multiplier, otherwise 0) + (institutional weight if (high[2] < low[1] AND close > low[1]) OR close <= lowest(low, supply/demand lookback)[1], otherwise 0) + (Fibonacci weight if close > Upper Fibonacci level AND close[1] <= Upper Fibonacci level, otherwise 0)
Calculation: Short score = (trend weight if short-term EMA < medium-term EMA AND medium-term EMA < long-term EMA AND close < short-term EMA, otherwise 0) + (economic weight if RSI value > overbought threshold, otherwise 0) + (volume weight if volume > Average volume * volume multiplier, otherwise 0) + (institutional weight if (low[2] > high[1] AND close < high[1]) OR close >= highest(high, supply/demand lookback)[1], otherwise 0) + (Fibonacci weight if close < Lower Fibonacci level AND close[1] >= Lower Fibonacci level, otherwise 0)
Long: Long score >= minimum score
Short: Long score < minimum score AND Short score >= minimum score
Calculation: Long stop = close on the long-signal bar - ATR value on that bar * initial stop multiplier; thereafter, max(previous long stop, low - ATR value * trailing multiplier) while long
Calculation: Long target = close on the long-signal bar + ATR value on that bar * take-profit multiplier
Calculation: Short stop = close on the short-signal bar + ATR value on that bar * initial stop multiplier; thereafter, min(previous short stop, high + ATR value * trailing multiplier) while short
Calculation: Short target = close on the short-signal bar - ATR value on that bar * take-profit multiplier
Exit: long, low <= Long stop OR high >= Long target
Exit: short, high >= Short stop OR low <= Short target