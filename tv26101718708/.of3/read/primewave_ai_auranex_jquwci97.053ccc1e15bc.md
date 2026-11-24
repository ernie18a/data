Calculation: volatility ratio = clamp((ATR(ATR lookback) − lowest(ATR(ATR lookback), adaptation lookback)) / (highest(ATR(ATR lookback), adaptation lookback) − lowest(ATR(ATR lookback), adaptation lookback)), 0, 1), with a midpoint fallback when the denominator is zero
Calculation: adaptive lookback(base lookback) = round(base lookback × (1 + adaptation strength × (1 − 2 × volatility ratio))), clamped between max(round(base lookback × (1 − adaptation strength)), minimum adaptive lookback) and round(base lookback × (1 + adaptation strength))
Calculation: Tenkan-Sen = midpoint(highest(high, conversion lookback), lowest(low, conversion lookback)); use adaptive lookback(conversion lookback) in Adaptive mode
Calculation: Kijun-Sen = midpoint(highest(high, base lookback), lowest(low, base lookback)); use adaptive lookback(base lookback) in Adaptive mode
Calculation: Senkou Span A = average(Tenkan-Sen, Kijun-Sen)
Calculation: Senkou Span B = midpoint(highest(high, Span B lookback), lowest(low, Span B lookback)); use adaptive lookback(Span B lookback) in Adaptive mode
Calculation: cloud top = max(Senkou Span A[displacement − 1], Senkou Span B[displacement − 1])
Calculation: cloud bottom = min(Senkou Span A[displacement − 1], Senkou Span B[displacement − 1])
Calculation: thin cloud = cloud top − cloud bottom < SMA(cloud top − cloud bottom, cloud-thickness average lookback) × thin-cloud multiplier
Calculation: volume confirmation = volume unavailable or zero, or volume > SMA(volume, volume lookback) × volume-confirmation multiplier
Calculation: momentum pulse = EMA(clamp(spread weight × spread + acceleration weight × (spread − spread[momentum acceleration lookback]) + cloud-slope weight × ((Senkou Span A − Senkou Span A[momentum cloud-slope lookback] − Senkou Span B + Senkou Span B[momentum cloud-slope lookback]) / ATR(ATR lookback)), lower momentum bound, upper momentum bound), momentum smoothing lookback), where spread = (Tenkan-Sen − Kijun-Sen) / ATR(ATR lookback)
Calculation: directional confluence score(side) = min(score cap, side-aligned cloud-position weight (above cloud for long, below cloud for short; in-cloud weight when inside; otherwise zero) + side-aligned Tenkan/Kijun weight + side-aligned Chikou weight (selected price source > source[displacement] for long, < for short) + cloud-direction weight (Senkou Span A change over score cloud-slope lookback > Senkou Span B change for long, ≤ for short) + cloud-thickness weight when not thin or thin-cloud weight when thin + volume weight when volume confirmation passes + momentum weight (strong-momentum weight when pulse exceeds the positive or negative strong-momentum threshold, moderate-momentum weight when pulse is on that side of zero) + acceleration weight (pulse rising while positive for long, falling while negative for short))
Calculation: long stop = cloud bottom − ATR(ATR lookback) × stop buffer when stop method is cloud edge; Kijun-Sen − ATR(ATR lookback) × stop buffer when stop method is Kijun; otherwise entry price − ATR(ATR lookback) × ATR-stop multiple
Calculation: short stop = cloud top + ATR(ATR lookback) × stop buffer when stop method is cloud edge; Kijun-Sen + ATR(ATR lookback) × stop buffer when stop method is Kijun; otherwise entry price + ATR(ATR lookback) × ATR-stop multiple
Calculation: risk distance = max(abs(entry price − stop), ATR(ATR lookback) × minimum risk-distance ATR multiplier)
Calculation: long third target = entry price + risk distance × third-target risk/reward multiple
Calculation: short third target = entry price − risk distance × third-target risk/reward multiple
Long: crossover(Tenkan-Sen, Kijun-Sen) AND (Kumo filter disabled OR not thin cloud) AND (volume filter disabled OR volume confirmation) AND (Chikou filter disabled OR selected price source > selected price source[displacement]) AND directional confluence score(long) ≥ minimum score AND chart bar confirmed AND chart bars since start ≥ max(Span B base lookback + displacement, warm-up floor)
Short: crossunder(Tenkan-Sen, Kijun-Sen) AND (Kumo filter disabled OR not thin cloud) AND (volume filter disabled OR volume confirmation) AND (Chikou filter disabled OR selected price source < selected price source[displacement]) AND directional confluence score(short) ≥ minimum score AND chart bar confirmed AND chart bars since start ≥ max(Span B base lookback + displacement, warm-up floor)
Long: breakout signals enabled AND close > cloud top AND close[1] ≤ cloud top[1] AND (volume unavailable or zero OR volume > SMA(volume, volume lookback) × breakout-volume multiplier) AND chart bar confirmed AND chart bars since start ≥ max(Span B base lookback + displacement, warm-up floor)
Short: breakout signals enabled AND close < cloud bottom AND close[1] ≥ cloud bottom[1] AND (volume unavailable or zero OR volume > SMA(volume, volume lookback) × breakout-volume multiplier) AND chart bar confirmed AND chart bars since start ≥ max(Span B base lookback + displacement, warm-up floor)
Long: breakout signals enabled AND retest signals enabled AND a bullish cloud breakout occurred between minimum retest age and retest window bars ago AND low ≤ cloud top AND close > cloud top AND chart bar confirmed AND chart bars since start ≥ max(Span B base lookback + displacement, warm-up floor)
Short: breakout signals enabled AND retest signals enabled AND a bearish cloud breakout occurred between minimum retest age and retest window bars ago AND high ≥ cloud bottom AND close < cloud bottom AND chart bar confirmed AND chart bars since start ≥ max(Span B base lookback + displacement, warm-up floor)
Long: close > cloud top AND Tenkan-Sen > Kijun-Sen
Short: close < cloud bottom AND Tenkan-Sen < Kijun-Sen
Long: close > cloud top
Short: close < cloud bottom
Long: Senkou Span A > Senkou Span B
Short: Senkou Span A ≤ Senkou Span B
Long: momentum pulse > 0
Short: momentum pulse < 0
Long: On chart bars, for any of T1, T2, or T3, the last completed bar of that timeframe has close > max(average(conversion Donchian midpoint(high, low, conversion lookback), base Donchian midpoint(high, low, base lookback)), Span B Donchian midpoint(high, low, Span B lookback)) AND conversion Donchian midpoint > base Donchian midpoint
Short: On chart bars, for any of T1, T2, or T3, the last completed bar of that timeframe has close < min(average(conversion Donchian midpoint(high, low, conversion lookback), base Donchian midpoint(high, low, base lookback)), Span B Donchian midpoint(high, low, Span B lookback)) AND conversion Donchian midpoint < base Donchian midpoint
Exit: long, TP/SL engine enabled AND (low ≤ long stop OR high ≥ long third target)
Exit: short, TP/SL engine enabled AND (high ≥ short stop OR low ≤ short third target)