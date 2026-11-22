Calculation: RS = close / market index close
Calculation: rebased RS = RS / RS[RS lookback]
Calculation: RS slope percent = (rebased RS - rebased RS[RS lookback]) / abs(rebased RS[RS lookback]) * 100
Calculation: RS days below percent = 100 * sum(rebased RS < EMA(rebased RS, RS lookback) ? 1 : 0, RS lookback) / RS lookback
Calculation: RS yearly change percent = (rebased RS - rebased RS[RS yearly lookback]) / abs(rebased RS[RS yearly lookback]) * 100
Calculation: RS score = min((RS slope percent < RS slope cut 1 ? RS slope points 1 : RS slope percent < RS slope cut 2 ? RS slope points 2 : RS slope percent < RS slope cut 3 ? RS slope points 3 : 0) + (RS days below percent > RS days cut 1 ? RS days points 1 : RS days below percent > RS days cut 2 ? RS days points 2 : RS days below percent > RS days cut 3 ? RS days points 3 : 0) + (RS yearly change percent < RS yearly cut 1 ? RS yearly points 1 : RS yearly change percent < RS yearly cut 2 ? RS yearly points 2 : 0), RS score cap)
Calculation: volume balance = sum(volume * (close > open ? 1 : close > close[1] ? partial volume weight : 0), volume window) / max(sum(volume * (close < open ? 1 : close < close[1] ? partial volume weight : 0), volume window), volume floor)
Calculation: volume score = volume balance < volume cut 1 ? volume points 1 : volume balance < volume cut 2 ? volume points 2 : volume balance < volume cut 3 ? volume points 3 : volume balance < volume cut 4 ? volume points 4 : volume balance < volume cut 5 ? volume points 5 : 0
Calculation: correction percent = (close - highest(high, annual high window)) / highest(high, annual high window) * 100
Calculation: correction score = correction percent < correction cut 1 ? correction points 1 : correction percent < correction cut 2 ? correction points 2 : correction percent < correction cut 3 ? correction points 3 : correction percent < correction cut 4 ? correction points 4 : correction percent < correction cut 5 ? correction points 5 : 0
Calculation: bars since breakout = high >= highest(high[1], breakout window) ? 0 : bars since breakout[1] + 1
Calculation: breakout score = (bars since breakout <= breakout fail window AND close < highest(high[1], breakout window)) ? breakout points : 0
Calculation: distribution score = min(RS score + volume score + correction score + breakout score, distribution cap)
Calculation: EMA ratio = EMA(close, momentum fast lookback, T2, last completed bar) / EMA(close, momentum slow lookback, T2, last completed bar)
Calculation: EMA ratio slope = EMA ratio - EMA ratio[momentum slope lookback] (chart bars)
Calculation: momentum slope score = EMA ratio slope < momentum cut 1 ? momentum points 1 : EMA ratio slope < momentum cut 2 ? momentum points 2 : EMA ratio slope < momentum cut 3 ? momentum points 3 : EMA ratio slope < 0 ? momentum points 4 : 0
Calculation: MA stack score = min((close(T2, last completed bar) < EMA(close, stack lookback 1, T2, last completed bar) ? stack points 1 : 0) + (EMA(close, stack lookback 1, T2, last completed bar) < EMA(close, stack lookback 2, T2, last completed bar) ? stack points 2 : 0) + (EMA(close, stack lookback 2, T2, last completed bar) < EMA(close, stack lookback 3, T2, last completed bar) ? stack points 3 : 0) + (EMA(close, stack lookback 3, T2, last completed bar) < EMA(close, stack lookback 4, T2, last completed bar) ? stack points 4 : 0), stack cap)
Calculation: distance above long MA percent = (close - EMA(close, long MA lookback)) / EMA(close, long MA lookback) * 100
Calculation: long MA share percent = 100 * sum(close < EMA(close, long MA lookback) ? 1 : 0, long MA window) / long MA window
Calculation: long MA score = (distance above long MA percent < long MA deep cut AND long MA share percent > long MA share cut) ? long MA points 1 : distance above long MA percent < long MA cut 1 ? long MA points 2 : distance above long MA percent < long MA cut 2 ? long MA points 3 : distance above long MA percent < long MA cut 3 ? long MA points 4 : distance above long MA percent < 0 ? long MA points 5 : 0
Calculation: slow EMA streak = sum(close(T2, last completed bar) < EMA(close, slow daily EMA lookback, T2, last completed bar) ? 1 : 0, streak window) (chart bars)
Calculation: duration score = slow EMA streak > duration cut 1 ? duration points 1 : slow EMA streak > duration cut 2 ? duration points 2 : slow EMA streak > duration cut 3 ? duration points 3 : slow EMA streak > duration cut 4 ? duration points 4 : 0
Calculation: momentum score = min(momentum slope score + MA stack score + long MA score + duration score, momentum cap)
Calculation: ATR ratio = ATR(fast ATR lookback) / ATR(slow ATR lookback)
Calculation: ATR ratio score = ATR ratio > ATR ratio cut 1 ? ATR ratio points 1 : ATR ratio > ATR ratio cut 2 ? ATR ratio points 2 : ATR ratio > ATR ratio cut 3 ? ATR ratio points 3 : ATR ratio > ATR ratio cut 4 ? ATR ratio points 4 : 0
Calculation: ATR asymmetry = sum(ATR(fast ATR lookback) * (close < open ? 1 : 0), volume window) / max(sum(ATR(fast ATR lookback), volume window), ATR share floor)
Calculation: ATR asymmetry score = ATR asymmetry > asymmetry cut 1 ? asymmetry points 1 : ATR asymmetry > asymmetry cut 2 ? asymmetry points 2 : ATR asymmetry > asymmetry cut 3 ? asymmetry points 3 : ATR asymmetry > asymmetry cut 4 ? asymmetry points 4 : 0
Calculation: candle body ratio = abs(close - open) / max(SMA(abs(close[1] - open[1]), candle window), body floor)
Calculation: candle score = (close < open AND candle body ratio > body cut 1 AND low < lowest(low[1], candle window)) ? candle points 1 : (close < open AND candle body ratio > body cut 1) ? candle points 2 : (close < open AND low < lowest(low[1], candle window)) ? candle points 3 : (close < open AND candle body ratio > body cut 2) ? candle points 4 : 0
Calculation: volatility score = min(ATR ratio score + ATR asymmetry score + candle score, volatility cap)
Calculation: passed gate count = (close(T1, last completed bar) < EMA(close, monthly EMA lookback, T1, last completed bar) ? 1 : 0) + (EMA(close, fast daily EMA lookback, T2, last completed bar) < EMA(close, mid daily EMA lookback, T2, last completed bar) ? 1 : 0) + (close(T2, last completed bar) < EMA(close, slow daily EMA lookback, T2, last completed bar) ? 1 : 0)
Calculation: gate multiplier = passed gate count = 3 ? full-gate multiplier : passed gate count = 2 ? two-gate multiplier : passed gate count = 1 ? one-gate multiplier : 0
Calculation: risk score = round(min(distribution score + momentum score + volatility score, risk cap) * gate multiplier)
Calculation: smoothed risk score = EMA(risk score, smoothing lookback)
Short: smoothed risk score crosses above high threshold
Short: smoothed risk score crosses above elevated threshold
Exit: short, smoothed risk score crosses below elevated threshold