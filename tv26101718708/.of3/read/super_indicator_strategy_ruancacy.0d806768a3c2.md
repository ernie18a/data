Calculation: volume spread = (close - open) * volume / (high - low)
Calculation: volume price level = volume spread + cumulative sum of volume spread, including the current bar
Calculation: volume price center = SMA(volume price level, center lookback)
Calculation: volume shadow = (volume price level - volume price center) / STDEV(volume price level - volume price center, volatility lookback) * STDEV(high - low, same volatility lookback)
Calculation: adjusted price = if volume shadow > 0 then high + volume shadow else low + volume shadow
Calculation: volume price trend = EMA(adjusted price, trend EMA lookback)
Calculation: lower band candidate = volume price trend - ATR multiplier * ATR(ATR lookback)
Calculation: upper band candidate = volume price trend + ATR multiplier * ATR(ATR lookback)
Calculation: lower trailing band = if prior close > prior lower trailing band then max(lower band candidate, prior lower trailing band) else lower band candidate; initialize the prior band to zero
Calculation: upper trailing band = if prior close < prior upper trailing band then min(upper band candidate, prior upper trailing band) else upper band candidate; initialize the prior band to zero
Calculation: trend state = bullish if close > prior upper trailing band, bearish if close < prior lower trailing band, otherwise prior trend state; initialize bullish
Calculation: trend score = score magnitude A if trend state is bullish, otherwise -score magnitude A
Calculation: source streak = prior source streak + score magnitude A if source price > SMA(source price, streak lookback), otherwise prior source streak - score magnitude A; initialize at zero
Calculation: Awesome Oscillator score = score magnitude A if Awesome Oscillator((high + low) / 2, shorter AO lookback, longer AO lookback) > 0, -score magnitude A if it is < 0, otherwise zero; shorter AO lookback is shorter than longer AO lookback
Calculation: momentum score = score magnitude A if Momentum(source price, momentum lookback) > 0, -score magnitude A if it is < 0, otherwise zero
Calculation: MACD histogram score = score magnitude C if MACD(source price, fast EMA lookback, slow EMA lookback, signal EMA lookback).histogram > its prior-bar value, otherwise -score magnitude C; fast EMA lookback is shorter than slow EMA lookback
Calculation: range term A = if prior close < open then max(open - prior close, high - low) else high - low
Calculation: range term B = if prior close > open then max(prior close - open, high - low) else high - low
Calculation: bullish candle range = if close = open then if high - close = close - low then if prior close > open then max(high - open, close - low) else range term A; else if high - close > close - low then if prior close < open then max(high - prior close, close - low) else high - open; else range term A; else if close < open then if prior close < open then max(high - prior close, close - low) else max(high - open, close - low); else range term A
Calculation: bearish candle range = if close = open then if high - close = close - low then if prior close < open then max(open - low, high - close) else range term B; else if high - close > close - low then range term B; else if prior close > open then max(prior close - low, high - close) else open - low; else if close < open then range term B; else if prior close > open then max(prior close - low, high - close) else max(open - low, high - close)
Calculation: candle score = score magnitude A if SMA(bullish candle range - bearish candle range, candle lookback) > 0, otherwise -score magnitude A
Calculation: positive setup count = if close > close[TD comparison lookback] then prior positive setup count, treating missing as zero, plus one; otherwise zero
Calculation: negative setup count = if close < close[TD comparison lookback] then prior negative setup count, treating missing as zero, plus one; otherwise zero
Calculation: positive setup delta = positive setup count - its value at the second most recent bar where it decreased from its prior-bar value
Calculation: negative setup delta = negative setup count - its value at the second most recent bar where it decreased from its prior-bar value
Calculation: setup score = score magnitude B if positive setup delta > 0, otherwise -score magnitude B if negative setup delta > 0, otherwise zero
Calculation: ROC score = score magnitude A if ROC(close, ROC lookback) > 0, otherwise -score magnitude A
Calculation: CCI score = score magnitude B if CCI(close, CCI lookback) > 0, otherwise -score magnitude B
Calculation: DMI score = score magnitude B if DI+(high, low, close, DMI lookback) - DI-(high, low, close, DMI lookback) >= 0, otherwise -score magnitude B
Calculation: movement direction = bullish if close > prior close, bearish if close < prior close, otherwise neutral
Calculation: trend direction = movement direction if it is non-neutral and differs from prior movement direction, otherwise prior trend direction, treating missing as neutral
Calculation: trend detection = rising(close, trend detection lookback) OR falling(close, trend detection lookback)
Calculation: wave direction = trend direction if it differs from prior wave direction and trend detection is true, otherwise prior wave direction, treating missing as neutral
Calculation: wave volume = prior wave volume + volume if wave direction equals its prior-bar value, otherwise volume
Calculation: up-wave volume = wave volume if wave direction is bullish, otherwise zero
Calculation: down-wave volume = zero if wave direction is bullish, otherwise wave volume
Calculation: wave score = score magnitude B if up-wave volume > down-wave volume, otherwise -score magnitude B
Calculation: zero-initialized Wilder average(value, lookback) = (value + prior average * (lookback - 1)) / lookback, treating a missing prior average as zero
Calculation: positive residual = max(close - EMA(close, residual EMA lookback), 0)
Calculation: negative residual = max(EMA(close, residual EMA lookback) - close, 0)
Calculation: residual strength = if zero-initialized Wilder average(negative residual, residual smoothing lookback) = 0 then normalized scale, otherwise normalized scale - normalized scale / (1 + zero-initialized Wilder average(positive residual, residual smoothing lookback) / zero-initialized Wilder average(negative residual, residual smoothing lookback))
Calculation: adaptive efficiency ratio = abs(source price - source price[efficiency lookback]) / SUM(abs(change(residual strength)), efficiency lookback)
Calculation: adaptive threshold = adaptive efficiency ratio * STDEV(residual strength * volatility scale factor, shorter volatility lookback) + (1 - adaptive efficiency ratio) * STDEV(residual strength * volatility scale factor, longer volatility lookback); shorter volatility lookback is shorter than longer volatility lookback
Calculation: adaptive strength line = residual strength during the initial warmup lookback; thereafter residual strength if it exceeds the prior line plus adaptive threshold or is below the prior line minus adaptive threshold, otherwise the prior line
Calculation: adaptive strength score = carry forward the last nonmissing value of score magnitude C if the adaptive strength line rises from its prior-bar value, -score magnitude C if it falls, and missing otherwise
Calculation: baseline score = score magnitude A if source price > Ichimoku base line(high, low, baseline lookback), otherwise -score magnitude A
Calculation: HMA score = score magnitude B if source price > HMA(source price, HMA lookback), otherwise -score magnitude B
Calculation: total score = adaptive strength score + setup score + trend score + ROC score + DMI score + CCI score + wave score + source streak + Awesome Oscillator score + momentum score + MACD histogram score + candle score + baseline score + HMA score
Calculation: smoothed score = SMA(total score, score smoothing lookback)
Long: smoothed score crosses above the signal threshold
Short: smoothed score crosses below the same signal threshold