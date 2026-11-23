Calculation: stop distance = ATR(ATR lookback) * stop multiplier
Calculation: last swing high = most recent non-NA PivotHigh(high, pivot lookback, pivot lookback)
Calculation: previous swing high = second most recent non-NA PivotHigh(high, pivot lookback, pivot lookback)
Calculation: last swing low = most recent non-NA PivotLow(low, pivot lookback, pivot lookback)
Calculation: previous swing low = second most recent non-NA PivotLow(low, pivot lookback, pivot lookback)
Calculation: bullish structure break = (close > last swing high AND close[1] <= last swing high) OR (last swing high > previous swing high AND close > last swing high)
Calculation: bearish structure break = (close < last swing low AND close[1] >= last swing low) OR (last swing low < previous swing low AND close < last swing low)
Calculation: bullish trend = EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback) AND close > EMA(close, longer EMA lookback)
Calculation: bearish trend = EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback) AND close < EMA(close, longer EMA lookback)
Calculation: bullish candle = close > open AND close - open > candle body factor * ATR(short ATR lookback)
Calculation: bearish candle = close < open AND open - close > candle body factor * ATR(short ATR lookback)
Calculation: normal volatility = low volatility bound <= NATR(ATR lookback) AND NATR(ATR lookback) <= high volatility bound
Calculation: active session = (UTC hour >= London start AND UTC hour < London end) OR (UTC hour >= New York start AND UTC hour < New York end)
Calculation: Asia session = UTC hour >= Asia start AND UTC hour < Asia end
Calculation: close position = high > low ? (close - low) / (high - low) : one half
Calculation: volume weight = volume > SMA(volume, volume lookback) ? pressure high-volume multiplier : pressure low-volume multiplier
Calculation: raw buy pressure = MIN(100, (close position * close-position weight + (high > low ? (MIN(close, open) - low) / (high - low) : 0) * wick weight + (bullish candle ? candle weight : 0)) * volume weight)
Calculation: raw sell pressure = MIN(100, ((1 - close position) * close-position weight + (high > low ? (high - MAX(close, open)) / (high - low) : 0) * wick weight + (bearish candle ? candle weight : 0)) * volume weight)
Calculation: buy pressure = EMA(((raw buy pressure + raw sell pressure) > 0) ? 100 * raw buy pressure / (raw buy pressure + raw sell pressure) : midpoint of the 0-100 scale, pressure lookback)
Calculation: sell pressure = 100 - buy pressure
Calculation: estimated delta = buy pressure - sell pressure
Calculation: cumulative delta = EMA(estimated delta, cumulative delta lookback)
Calculation: order flow bullish = buy pressure > pressure threshold AND estimated delta > estimated delta threshold AND cumulative delta > 0
Calculation: order flow bearish = sell pressure > pressure threshold AND estimated delta < -estimated delta threshold AND cumulative delta < 0
Calculation: MACD hist = MACD histogram(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback)
Calculation: stochastic K = SMA(Stochastic(close, high, low, stochastic lookback), stochastic smoothing)
Calculation: stochastic D = SMA(stochastic K, stochastic smoothing)
Calculation: HTF bullish count = [close(T1, last completed bar) > EMA(close, longer EMA lookback, T1, last completed bar)] + [close(T2, last completed bar) > EMA(close, longer EMA lookback, T2, last completed bar) AND RSI(close, RSI lookback, T2, last completed bar) > HTF RSI threshold] + [close(T3, last completed bar) > EMA(close, longer EMA lookback, T3, last completed bar)], where [x] is 1 if x holds, else 0
Calculation: trend factor = (bullish trend OR bearish trend) ? trend aligned score : trend unaligned score
Calculation: momentum factor = (((RSI(close, RSI lookback) > core band A low) AND (RSI(close, RSI lookback) < core band A high)) OR ((RSI(close, RSI lookback) > core band B low) AND (RSI(close, RSI lookback) < core band B high))) ? momentum core score : (((RSI(close, RSI lookback) > outer band low) AND (RSI(close, RSI lookback) < outer band high)) ? momentum outer score : momentum other score)
Calculation: MACD factor = MACD hist != 0 ? MACD agreement score : (|MACD hist| < |MACD hist[1]| ? MACD shrinking score : MACD other score)
Calculation: volume confirmation factor = volume > SMA(volume, volume lookback) * volume spike factor ? volume spike score : (volume > SMA(volume, volume lookback) ? volume above-average score : volume other score)
Calculation: structure factor = (bullish structure break OR bearish structure break) ? structure score : no-structure score
Calculation: order flow factor = (order flow bullish OR order flow bearish) ? order flow signal score : order flow neutral score
Calculation: HTF factor = (HTF bullish count = 0 OR HTF bullish count = number of HTF checks) ? HTF agreement score : HTF partial score
Calculation: session factor = active session ? active session score : (Asia session ? Asia session score : off-session score)
Calculation: zone factor = ((close < Donchian midline(range lookback)) AND bullish trend OR (close > Donchian midline(range lookback)) AND bearish trend) ? zone aligned score : zone other score
Calculation: AI confidence = ROUND(100 * (trend weight * trend factor + momentum weight * momentum factor + MACD weight * MACD factor + volume weight * volume confirmation factor + structure weight * structure factor + order flow weight * order flow factor + HTF weight * HTF factor + session weight * session factor + zone weight * zone factor) / (trend weight + momentum weight + MACD weight + volume weight + structure weight + order flow weight + HTF weight + session weight + zone weight))
Calculation: long stop level = trailing enabled ? highest(close - stop distance, since entry bar) : ((breakeven enabled AND highest(close - stop distance, since entry bar) >= entry price) ? entry price : entry price - stop distance at entry bar)
Calculation: short stop level = trailing enabled ? lowest(close + stop distance, since entry bar) : ((breakeven enabled AND lowest(close + stop distance, since entry bar) <= entry price) ? entry price : entry price + stop distance at entry bar)
Long: bullish structure break
Long: close[1] < open[1] AND close > high[1] AND bullish candle AND volume > SMA(volume, volume lookback)
Long: low > high[2] AND low - high[2] > FVG gap factor * ATR(ATR lookback)
Long: order flow bullish
Long: estimated delta > delta label threshold
Long: bullish trend AND RSI(close, RSI lookback) > long RSI lower bound AND RSI(close, RSI lookback) < long RSI upper bound AND MACD hist > 0 AND MACD hist > MACD hist[1] AND volume > SMA(volume, volume lookback) * volume threshold multiplier AND normal volatility AND (NOT session filter enabled OR active session) AND buy pressure > sell pressure AND AI confidence >= AI confidence minimum AND (NOT MTF filter enabled OR HTF bullish count >= required HTF count) AND (NOT order flow filter enabled OR order flow bullish OR (neutral order flow allowed AND NOT order flow bearish)) AND stochastic K > stochastic D AND stochastic K < long stochastic cap AND (NOT premium-discount filter enabled OR close < Donchian midline(range lookback)) AND (bullish structure break OR (close > EMA(close, middle EMA lookback) AND close > EMA(close, longer EMA lookback)))
Short: bearish structure break
Short: close[1] > open[1] AND close < low[1] AND bearish candle AND volume > SMA(volume, volume lookback)
Short: high < low[2] AND low[2] - high > FVG gap factor * ATR(ATR lookback)
Short: order flow bearish
Short: estimated delta < -delta label threshold
Short: bearish trend AND RSI(close, RSI lookback) > short RSI lower bound AND RSI(close, RSI lookback) < short RSI upper bound AND MACD hist < 0 AND MACD hist < MACD hist[1] AND volume > SMA(volume, volume lookback) * volume threshold multiplier AND normal volatility AND (NOT session filter enabled OR active session) AND sell pressure > buy pressure AND AI confidence >= AI confidence minimum AND (NOT MTF filter enabled OR number of HTF checks - HTF bullish count >= required HTF count) AND (NOT order flow filter enabled OR order flow bearish OR (neutral order flow allowed AND NOT order flow bullish)) AND stochastic K < stochastic D AND stochastic K > short stochastic floor AND (NOT premium-discount filter enabled OR close > Donchian midline(range lookback)) AND (bearish structure break OR (close < EMA(close, middle EMA lookback) AND close < EMA(close, longer EMA lookback)))
Exit: long, low <= long stop level
Exit: long, high >= entry price + reward-to-risk multiple * stop distance at entry bar
Exit: short, high >= short stop level
Exit: short, low <= entry price - reward-to-risk multiple * stop distance at entry bar