Calculation: indicator inputs = selected data source's T1 OHLCV values with lookahead off, evaluated on chart bars using the current T1 bar, which may still be forming in realtime
Calculation: enabled indicator vote = bullish for its enabled Long condition, bearish for its enabled Short condition, and neutral otherwise; disabled indicators are excluded
Calculation: enabled bullish vote count = count of enabled bullish indicator votes
Calculation: enabled bearish vote count = count of enabled bearish indicator votes
Calculation: consensus percentage = the greater of the enabled bullish and bearish vote counts divided by the enabled indicator count, or one if none are enabled
Calculation: dominant side = bullish when the enabled bullish vote count is greater than or equal to the enabled bearish vote count, otherwise bearish
Calculation: phase = on confirmed chart bars while T1 is shorter than T2, reset to unset at each T2 boundary, set to the dominant side when consensus first reaches the neutral threshold, then change only when a later non-neutral dominant side differs; neutral readings retain the phase
Long: RSI enabled AND (RSI(close, RSI lookback) ≤ lower threshold OR (midpoint threshold < RSI(close, RSI lookback) < upper threshold)), with ascending lower, midpoint, and upper thresholds
Short: RSI enabled AND (RSI(close, RSI lookback) ≥ upper threshold OR (lower threshold < RSI(close, RSI lookback) < midpoint threshold)), with ascending lower, midpoint, and upper thresholds
Long: Stochastic enabled AND (%K ≤ lower threshold OR (lower threshold < %K < upper threshold AND %K > %D)), where %K = SMA(Stochastic(high, low, close, lookback), smoothing lookback) and %D = SMA(%K, the same smoothing lookback)
Short: Stochastic enabled AND (%K ≥ upper threshold OR (lower threshold < %K < upper threshold AND %K < %D)), where %K = SMA(Stochastic(high, low, close, lookback), smoothing lookback) and %D = SMA(%K, the same smoothing lookback)
Long: CCI enabled AND CCI(HLC3, CCI lookback) > center threshold
Short: CCI enabled AND CCI(HLC3, CCI lookback) < center threshold
Long: MACD enabled AND MACD line(close, fast lookback, slow lookback, signal lookback) > MACD signal line, with fast lookback shorter than slow lookback
Short: MACD enabled AND MACD line(close, fast lookback, slow lookback, signal lookback) < MACD signal line, with fast lookback shorter than slow lookback
Long: Awesome Oscillator enabled AND Awesome Oscillator(high, low, shorter lookback, longer lookback) > center threshold
Short: Awesome Oscillator enabled AND Awesome Oscillator(high, low, shorter lookback, longer lookback) < center threshold
Long: Momentum enabled AND Momentum(close, lookback) > center threshold
Short: Momentum enabled AND Momentum(close, lookback) < center threshold
Long: Williams %R enabled AND (Williams %R(high, low, close, lookback) ≤ lower threshold OR (midpoint threshold < Williams %R(high, low, close, lookback) < upper threshold)), with ascending lower, midpoint, and upper thresholds and the midpoint used when the range is zero
Short: Williams %R enabled AND (Williams %R(high, low, close, lookback) ≥ upper threshold OR (lower threshold < Williams %R(high, low, close, lookback) < midpoint threshold)), with ascending lower, midpoint, and upper thresholds and the midpoint used when the range is zero
Long: Stochastic RSI enabled AND (%K ≤ lower threshold OR (lower threshold < %K < upper threshold AND %K > %D)), where RSI uses one lookback also used for the Stochastic RSI range, and %K and %D use the same smoothing lookback
Short: Stochastic RSI enabled AND (%K ≥ upper threshold OR (lower threshold < %K < upper threshold AND %K < %D)), where RSI uses one lookback also used for the Stochastic RSI range, and %K and %D use the same smoothing lookback
Long: Ultimate Oscillator enabled AND (Ultimate Oscillator(high, low, close, shorter lookback, medium lookback, longer lookback) ≤ lower threshold OR (midpoint threshold < Ultimate Oscillator(high, low, close, shorter lookback, medium lookback, longer lookback) < upper threshold)), with ascending lookbacks and ascending lower, midpoint, and upper thresholds
Short: Ultimate Oscillator enabled AND (Ultimate Oscillator(high, low, close, shorter lookback, medium lookback, longer lookback) ≥ upper threshold OR (lower threshold < Ultimate Oscillator(high, low, close, shorter lookback, medium lookback, longer lookback) < midpoint threshold)), with ascending lookbacks and ascending lower, midpoint, and upper thresholds
Long: Bull/Bear Power enabled AND close > EMA(close, Bull/Bear Power lookback)
Short: Bull/Bear Power enabled AND close < EMA(close, Bull/Bear Power lookback)
Long: (shortest-lookback EMA enabled AND close > EMA(close, shortest lookback)) OR (next-shortest-lookback EMA enabled AND close > EMA(close, next-shortest lookback)) OR (middle-lookback EMA enabled AND close > EMA(close, middle lookback)) OR (next-longest-lookback EMA enabled AND close > EMA(close, next-longest lookback)) OR (longest-lookback EMA enabled AND close > EMA(close, longest lookback)) OR (shortest-lookback SMA enabled AND close > SMA(close, shortest lookback)) OR (next-shortest-lookback SMA enabled AND close > SMA(close, next-shortest lookback)) OR (middle-lookback SMA enabled AND close > SMA(close, middle lookback)) OR (next-longest-lookback SMA enabled AND close > SMA(close, next-longest lookback)) OR (longest-lookback SMA enabled AND close > SMA(close, longest lookback)); the five lookbacks ascend and each EMA/SMA pair uses the same lookback
Short: (shortest-lookback EMA enabled AND close < EMA(close, shortest lookback)) OR (next-shortest-lookback EMA enabled AND close < EMA(close, next-shortest lookback)) OR (middle-lookback EMA enabled AND close < EMA(close, middle lookback)) OR (next-longest-lookback EMA enabled AND close < EMA(close, next-longest lookback)) OR (longest-lookback EMA enabled AND close < EMA(close, longest lookback)) OR (shortest-lookback SMA enabled AND close < SMA(close, shortest lookback)) OR (next-shortest-lookback SMA enabled AND close < SMA(close, next-shortest lookback)) OR (middle-lookback SMA enabled AND close < SMA(close, middle lookback)) OR (next-longest-lookback SMA enabled AND close < SMA(close, next-longest lookback)) OR (longest-lookback SMA enabled AND close < SMA(close, longest lookback)); the five lookbacks ascend and each EMA/SMA pair uses the same lookback
Long: VWMA enabled AND close > VWMA(close, volume, VWMA lookback)
Short: VWMA enabled AND close < VWMA(close, volume, VWMA lookback)
Long: HMA enabled AND close > HMA(close, HMA lookback)
Short: HMA enabled AND close < HMA(close, HMA lookback)
Long: enabled bullish vote count > enabled bearish vote count
Short: enabled bearish vote count > enabled bullish vote count
Long: consensus percentage ≥ neutral threshold AND ((enabled bullish vote count ≥ enabled bearish vote count AND (consensus percentage < extreme threshold OR contrarian mode disabled)) OR (enabled bearish vote count > enabled bullish vote count AND consensus percentage ≥ extreme threshold AND contrarian mode enabled))
Short: consensus percentage ≥ neutral threshold AND ((enabled bearish vote count > enabled bullish vote count AND (consensus percentage < extreme threshold OR contrarian mode disabled)) OR (enabled bullish vote count ≥ enabled bearish vote count AND consensus percentage ≥ extreme threshold AND contrarian mode enabled))
Long: phase is bullish
Short: phase is bearish
Long: on a confirmed chart bar, phase changes from bearish to bullish
Short: on a confirmed chart bar, phase changes from bullish to bearish
Long: on a confirmed chart bar, phase changes from bearish to bullish AND ((consensus filter mode is at least AND consensus percentage ≥ consensus filter threshold) OR (consensus filter mode is at most AND consensus percentage ≤ consensus filter threshold)) AND (EMA filter disabled OR low > EMA(selected OHLC-derived price source, EMA filter lookback))
Short: on a confirmed chart bar, phase changes from bullish to bearish AND ((consensus filter mode is at least AND consensus percentage ≥ consensus filter threshold) OR (consensus filter mode is at most AND consensus percentage ≤ consensus filter threshold)) AND (EMA filter disabled OR high < EMA(selected OHLC-derived price source, EMA filter lookback))