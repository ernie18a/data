Calculation: safeDiv(a, b) = a / b when b != 0, otherwise 0
Calculation: ATR ratio = safeDiv(ATR(ATR lookback), SMA(ATR(ATR lookback), ATR-average lookback))
Calculation: trend stack score = stack points per slot × (count of each EMA above the next longer EMA − count of each EMA below the next longer EMA), using five EMAs with strictly increasing trend lookbacks
Calculation: Dow pivot score = pivot points per comparison × (rising confirmed pivot highs + rising confirmed pivot lows − falling confirmed pivot highs − falling confirmed pivot lows), comparing each latest pivot with its preceding pivot; both pivot types use the same left and right lookback
Calculation: ADX direction score = strong ADX points in the direction of the dominant DI when ADX exceeds the strong threshold; otherwise weak ADX points in that direction when ADX exceeds the weak threshold; otherwise zero, using DMI with separate DI and ADX smoothing lookbacks
Calculation: trend score = clamp(stack score × stack weight + Dow pivot score × pivot weight + ADX direction score × ADX weight, trend score bounds)
Calculation: RSI momentum score = (EMA(RSI(close, momentum RSI lookback), RSI smoothing lookback) − RSI midpoint) × RSI scale
Calculation: MACD momentum score = clamp(MACD histogram(close, fast lookback, slow lookback, signal lookback) × histogram scale / (ATR(ATR lookback) + denominator epsilon), momentum score bounds)
Calculation: momentum score = clamp(RSI momentum score × RSI weight + MACD momentum score × MACD weight, momentum score bounds)
Calculation: Bollinger width = Bollinger Band width as a percentage of its basis, using the Bollinger lookback and deviation multiplier
Calculation: width expansion = Bollinger width > SMA(Bollinger width, width-average lookback) × expansion multiplier
Calculation: width squeeze = Bollinger width < SMA(Bollinger width, width-average lookback) × squeeze multiplier
Calculation: volatility score = clamp((width expansion AND ATR ratio strictly between healthy-volatility bounds AND abs(close − open) / (high − low) > strong-candle threshold ? candle direction × volatility vote points : 0) + clamp((close − close[price-slope lookback]) / ATR(ATR lookback) × slope scale, negative slope cap, positive slope cap), volatility score bounds), where candle direction is positive when close > open, negative when close < open, and zero otherwise
Calculation: market regime = Trend when ADX >= regime ADX threshold and at least the required number of trend EMA comparisons align in one direction; otherwise Volatile when ATR ratio >= volatile threshold; otherwise Quiet when width squeeze or ATR ratio <= quiet threshold; otherwise Range
Calculation: axis reliability weight = minimum axis weight + (maximum axis weight − minimum axis weight) × that axis's online EWMA reliability, with reliability learned from historical axis prediction correctness
Calculation: axis weight = zero when its axis is disabled; otherwise axis reliability weight × regime multiplier, with separate multipliers for each axis in Trend, Volatile, and Range regimes and one shared multiplier in Quiet regime
Calculation: higher-timeframe verdict on chart bars = positive when EMA(close, higher-timeframe fast lookback) > EMA(close, higher-timeframe slow lookback) AND RSI(close, higher-timeframe RSI lookback) > higher-timeframe RSI midpoint; negative when both comparisons are reversed; otherwise zero; evaluate separately on T1 and T2 using each still-forming higher-timeframe bar
Calculation: raw score = safeDiv(trend score × trend axis weight + momentum score × momentum axis weight + volatility score × volatility axis weight, (trend axis weight + momentum axis weight + volatility axis weight) × score normalization) × score normalization
Calculation: final score = clamp(raw score + one MTF bonus per enabled higher timeframe, final score bounds), where a nonzero higher-timeframe verdict matching the raw score sign adds the bonus, a nonzero opposing verdict subtracts it, and a zero verdict adds nothing
Calculation: active threshold = the Q-learning-selected threshold from evenly spaced candidates across the selected preset threshold interval; choose the highest learned Q value, with epsilon-greedy exploration, or the interval midpoint when adaptive thresholds are disabled
Calculation: axis agreement = up-lean count > down-lean count or down-lean count > up-lean count, counting enabled axes with scores above the positive lean threshold or below its negative; leaning-axis spread is maximum minus minimum lean score, and spread passes when it is <= cross-axis tolerance × spread multiplier; tolerance passes only when axis agreement and spread pass
Calculation: strong long condition = axis agreement favors up AND spread passes AND trend score > positive lean threshold AND final score >= active threshold
Calculation: strong short condition = axis agreement favors down AND spread passes AND trend score < negative lean threshold AND final score <= negative active threshold
Calculation: signal latch = initialize neutral; on each confirmed chart bar set to long when strong long holds, set to short when strong short holds, reset to neutral when neither strong condition holds and abs(final score) < active threshold − rearm margin, otherwise retain its prior side
Long: EMA(close, shortest trend lookback) > EMA(close, next longer trend lookback)
Short: EMA(close, shortest trend lookback) <= EMA(close, next longer trend lookback)
Long: EMA(close, second-shortest trend lookback) > EMA(close, middle trend lookback)
Short: EMA(close, second-shortest trend lookback) <= EMA(close, middle trend lookback)
Long: EMA(close, middle trend lookback) > EMA(close, longest trend lookback)
Short: EMA(close, middle trend lookback) <= EMA(close, longest trend lookback)
Long: trend score > axis display threshold
Short: trend score < negative axis display threshold
Long: momentum score > axis display threshold
Short: momentum score < negative axis display threshold
Long: volatility score > axis display threshold
Short: volatility score < negative axis display threshold
Long: higher-timeframe alignment is enabled AND T1 verdict is positive
Short: higher-timeframe alignment is enabled AND T1 verdict is negative
Long: higher-timeframe alignment is enabled AND T2 verdict is positive
Short: higher-timeframe alignment is enabled AND T2 verdict is negative
Long: final score >= active threshold × bar-color fraction
Short: final score <= negative active threshold × bar-color fraction
Long: strong long condition AND signal latch is not long
Short: strong short condition AND signal latch is not short