Calculation: Supertrend mean = (Supertrend(factor 1, ATR length) + Supertrend(factor 2, ATR length) + Supertrend(factor 3, ATR length)) / 3, with factor 1 < factor 2 < factor 3
Calculation: Smoothed supertrend mean = EMA(Supertrend mean, smoothing length)
Calculation: Adaptive average(x, lookback) = Adaptive average(x, lookback)[1] + SMA(flag, lookback)^2 * (x - Adaptive average(x, lookback)[1]), where flag = 1 if highest(high, lookback) > highest(high, lookback)[1] or lowest(low, lookback) < lowest(low, lookback)[1], else 0
Calculation: Adaptive midline = (Adaptive average(high, channel length) + Adaptive average(low, channel length)) / 2
Calculation: T1 RSI = RSI(close, RSI length, T1, last completed bar)
Calculation: T2 MACD line = MACD line(close, fast length, slow length, T2, last completed bar), with fast length < slow length
Calculation: T2 MACD signal = MACD signal(close, fast length, slow length, signal length, T2, last completed bar)
Calculation: T3 volume average = SMA(volume, volume lookback, T3, last completed bar)
Long: low < Supertrend mean AND close > Smoothed supertrend mean AND close[1] > Adaptive midline AND close > Adaptive midline AND T1 RSI > RSI buy threshold AND T2 MACD line > T2 MACD signal AND volume(T3, last completed bar) > T3 volume average * volume multiplier AND position side is flat
Short: high > Supertrend mean AND close < Smoothed supertrend mean AND close[1] < Adaptive midline AND close < Adaptive midline AND T1 RSI < RSI sell threshold AND T2 MACD line < T2 MACD signal AND volume(T3, last completed bar) > T3 volume average * volume multiplier AND position side is flat
Exit: Long, close[1] crosses under Smoothed supertrend mean
Exit: Short, close[1] crosses above Smoothed supertrend mean