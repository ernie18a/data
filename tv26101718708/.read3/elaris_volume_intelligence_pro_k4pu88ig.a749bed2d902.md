Calculation: Candle range = MAX(high - low, minimum price increment)
Calculation: Close location = CLAMP((close - low) / candle range, lower close-location bound, upper close-location bound)
Calculation: Volume delta = volume * close location - volume * (one - close location)
Calculation: Normalized delta = if SMA(volume, volume baseline lookback) is positive then CLAMP(volume delta / SMA(volume, volume baseline lookback) * delta normalization scale, lower normalized-delta bound, upper normalized-delta bound), otherwise zero
Calculation: Volume flow = EMA(EMA(normalized delta, flow smoothing lookback), flow smoothing lookback)
Calculation: Weighted participation score = CLAMP(volume flow * flow weight + normalized delta * delta weight + (close location - score midpoint) * score scale * close-location weight, lower score bound, upper score bound)
Long: RelativeVolume(volume, volume baseline lookback) >= climax relative-volume threshold AND if STDEV(volume, volume z-score lookback) is positive then (volume - SMA(volume, volume baseline lookback)) / STDEV(volume, volume z-score lookback) else zero >= extreme volume z-score threshold AND close > open AND close location >= bullish climax close-location threshold
Long: RelativeVolume(volume, volume baseline lookback) >= high relative-volume threshold AND candle range / ATR(ATR lookback) <= absorption range threshold AND close location >= bullish absorption close-location threshold AND close <= open
Long: low < LOWEST(low, divergence lookback)[1] AND CVD(volume delta) >= LOWEST(CVD(volume delta), divergence lookback)[1] AND RelativeVolume(volume, volume baseline lookback) > baseline relative-volume threshold
Long: volume flow > positive pressure flow threshold AND normalized delta > zero AND RelativeVolume(volume, volume baseline lookback) > baseline relative-volume threshold
Long: Weighted participation score >= bullish state threshold
Long: volume flow >= bullish state threshold
Long: normalized delta >= zero
Short: RelativeVolume(volume, volume baseline lookback) >= climax relative-volume threshold AND if STDEV(volume, volume z-score lookback) is positive then (volume - SMA(volume, volume baseline lookback)) / STDEV(volume, volume z-score lookback) else zero >= extreme volume z-score threshold AND close < open AND close location <= bearish climax close-location threshold
Short: RelativeVolume(volume, volume baseline lookback) >= high relative-volume threshold AND candle range / ATR(ATR lookback) <= absorption range threshold AND close location <= bearish absorption close-location threshold AND close >= open
Short: high > HIGHEST(high, divergence lookback)[1] AND CVD(volume delta) <= HIGHEST(CVD(volume delta), divergence lookback)[1] AND RelativeVolume(volume, volume baseline lookback) > baseline relative-volume threshold
Short: volume flow < negative pressure flow threshold AND normalized delta < zero AND RelativeVolume(volume, volume baseline lookback) > baseline relative-volume threshold
Short: Weighted participation score <= bearish state threshold
Short: volume flow <= bearish state threshold
Short: normalized delta < zero