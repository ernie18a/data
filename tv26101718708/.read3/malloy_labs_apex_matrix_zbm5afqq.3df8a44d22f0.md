Calculation: EMA spread strength = abs((EMA(close, shorter EMA lookback) - EMA(close, longer EMA lookback)) / EMA(close, longer EMA lookback)) * 100
Calculation: T1 conversion midpoint = Donchian midpoint(high, low, shortest conversion lookback, T1 forming bar), calculated on T1 bars and mapped to chart bars with lookahead off (forming in realtime; historical values appear at T1 close)
Calculation: T1 base midpoint = Donchian midpoint(high, low, middle base lookback, T1 forming bar), calculated on T1 bars and mapped to chart bars with lookahead off (forming in realtime; historical values appear at T1 close)
Calculation: T1 span midpoint = Donchian midpoint(high, low, longest span lookback, T1 forming bar), calculated on T1 bars and mapped to chart bars with lookahead off (forming in realtime; historical values appear at T1 close)
Calculation: T1 lead = average(T1 conversion midpoint, T1 base midpoint), on chart bars using mapped T1 values
Calculation: Cloud distance strength = abs((T1 close - average(T1 lead, T1 span midpoint)) / T1 close) * 100, on chart bars using mapped T1 values
Calculation: T2 MACD histogram = MACD(close, faster MACD lookback, slower MACD lookback, MACD signal lookback).histogram, calculated on T2 bars using the forming bar in realtime and mapped to chart bars with lookahead off (historical values appear at T2 close)
Calculation: T3 RSI = RSI(close, RSI lookback), calculated on T3 bars using the forming bar in realtime and mapped to chart bars with lookahead off (historical values appear at T3 close)
Calculation: RSI distance strength = abs(T3 RSI - RSI midpoint) / RSI midpoint * 100, on chart bars using mapped T3 values
Calculation: MACD magnitude = abs(T2 MACD histogram) * MACD magnitude multiplier
Calculation: EMA bullish score = if EMA scoring enabled AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND change(EMA spread strength, momentum lookback) > 0 AND close > EMA(close, shorter EMA lookback) then min(EMA spread strength * EMA score multiplier, common score cap) else 0
Calculation: EMA bearish score = if EMA scoring enabled AND EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback) AND change(EMA spread strength, momentum lookback) < 0 AND close < EMA(close, shorter EMA lookback) then min(EMA spread strength * EMA score multiplier, common score cap) else 0
Calculation: Cloud bullish score = if Ichimoku scoring enabled AND T1 close > T1 lead AND T1 close > T1 span midpoint AND T1 conversion midpoint > T1 base midpoint then min(Cloud distance strength * cloud score multiplier, common score cap) else 0
Calculation: Cloud bearish score = if Ichimoku scoring enabled AND T1 close < T1 lead AND T1 close < T1 span midpoint then min(Cloud distance strength * cloud score multiplier, common score cap) else 0
Calculation: MACD bullish score = if MACD scoring enabled AND T2 MACD histogram > 0 AND change(T2 MACD histogram, momentum lookback) > 0 on chart bars using mapped T2 values then min(MACD magnitude * MACD score multiplier, common score cap) else 0
Calculation: MACD bearish score = if MACD scoring enabled AND T2 MACD histogram <= 0 AND change(T2 MACD histogram, momentum lookback) < 0 on chart bars using mapped T2 values then min(MACD magnitude * MACD score multiplier, common score cap) else 0
Calculation: RSI bullish score = if RSI scoring enabled AND T3 RSI > RSI bullish lower bound AND T3 RSI < RSI bullish upper bound AND change(T3 RSI, momentum lookback) > 0 on chart bars using mapped T3 values then min(RSI distance strength * RSI score multiplier, common score cap) else 0
Calculation: RSI bearish score = if RSI scoring enabled AND T3 RSI > RSI bearish-score lower bound AND T3 RSI < RSI bearish-score upper bound AND change(T3 RSI, momentum lookback) < 0 on chart bars using mapped T3 values then min(RSI distance strength * RSI score multiplier, common score cap) else 0
Calculation: Bullish score total = EMA bullish score + Cloud bullish score + MACD bullish score + RSI bullish score
Calculation: Bearish score total = EMA bearish score + Cloud bearish score + MACD bearish score + RSI bearish score
Calculation: Smoothed net score = EMA(Bullish score total - Bearish score total, smoothing lookback)
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND change(EMA spread strength, momentum lookback) > 0 AND close > EMA(close, shorter EMA lookback)
Short: EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback)
Long: T1 close > T1 lead AND T1 close > T1 span midpoint AND T1 conversion midpoint > T1 base midpoint
Short: NOT (T1 close > T1 lead AND T1 close > T1 span midpoint AND T1 conversion midpoint > T1 base midpoint)
Long: T2 MACD histogram > 0 AND change(T2 MACD histogram, momentum lookback) > 0 on chart bars using mapped T2 values
Short: T2 MACD histogram <= 0 AND change(T2 MACD histogram, momentum lookback) < 0 on chart bars using mapped T2 values
Long: T3 RSI > RSI bullish lower bound AND T3 RSI < RSI bullish upper bound AND change(T3 RSI, momentum lookback) > 0 on chart bars using mapped T3 values
Short: T3 RSI < RSI bullish lower bound AND change(T3 RSI, momentum lookback) < 0 on chart bars using mapped T3 values
Long: Smoothed net score > signal threshold
Short: Smoothed net score < -signal threshold