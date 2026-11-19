Calculation: Cloud width = ATR(ATR lookback) * cloud width multiplier
Calculation: Upper cloud = HMA(close, HMA lookback) + cloud width
Calculation: Lower cloud = HMA(close, HMA lookback) - cloud width
Calculation: Safe ratio(n, d) = n / d if d is nonzero and available, otherwise 0
Calculation: Retest score(side) = floor(min(min(Safe ratio(max(side=long ? upper cloud - low : high - lower cloud, 0), cloud width) * penetration weight, penetration cap) + min(Safe ratio(volume, max(SMA(volume, volume lookback), volume denominator floor)) * volume weight, volume cap) + min(max(side=long ? long RSI score ceiling - RSI(close, RSI lookback) : RSI(close, RSI lookback) - short RSI score floor, 0) * RSI score weight, RSI score cap) + min(ADX(ADX lookback) * ADX score weight, ADX score cap), total score cap))
Calculation: Bull timeframe count = count of T1 through T5 where the fast EMA is greater than the slow EMA, calculated on each T's bars and sampled onto chart bars with lookahead off (current T bar while forming in real time; completed T-bar values historically)
Long: EMA(close, fast lookback equal to half the HMA lookback) > EMA(close, slow lookback equal to the HMA lookback)
Short: EMA(close, fast lookback equal to half the HMA lookback) <= EMA(close, slow lookback equal to the HMA lookback)
Long: For each of T1 through T5, EMA(close, fast lookback equal to half the HMA lookback) > EMA(close, slow lookback equal to the HMA lookback), calculated on T bars and sampled onto chart bars with lookahead off (current T bar while forming in real time; completed T-bar values historically)
Short: For each of T1 through T5, EMA(close, fast lookback equal to half the HMA lookback) <= EMA(close, slow lookback equal to the HMA lookback), calculated on T bars and sampled onto chart bars with lookahead off (current T bar while forming in real time; completed T-bar values historically)
Long: Bull timeframe count >= minimum bull count
Short: Bull timeframe count <= maximum bull count
Long: RSI(close, RSI lookback) < long RSI tint threshold
Short: RSI(close, RSI lookback) > short RSI tint threshold
Long: low <= upper cloud AND close > HMA(close, HMA lookback) AND close > open AND EMA(close, fast lookback equal to half the HMA lookback) > EMA(close, slow lookback equal to the HMA lookback) AND chart bar index >= max(HMA lookback * warmup lookback multiplier, minimum warmup chart bars) AND chart bar is confirmed AND Retest score(long) >= minimum retest score
Short: high >= lower cloud AND close < HMA(close, HMA lookback) AND close < open AND EMA(close, fast lookback equal to half the HMA lookback) < EMA(close, slow lookback equal to the HMA lookback) AND chart bar index >= max(HMA lookback * warmup lookback multiplier, minimum warmup chart bars) AND chart bar is confirmed AND Retest score(short) >= minimum retest score