Calculation: Structure(pivot window, break confirmation) = +1 if the latest swing break is upward, -1 if downward, 0 before any break; a swing high is a bar whose high exceeds the highs of the pivot window bars on each side, known once those bars have completed; a swing low is a bar whose low is below the lows of the pivot window bars on each side, known once those bars have completed; an upward break is a bar where the close (the high if break confirmation is wick) exceeds the latest swing high while that swing high is not yet broken; a downward break is a bar where the close (the low if break confirmation is wick) is below the latest swing low while that swing low is not yet broken
Calculation: Senkou Span A (no forward shift) = (Highest(high, Ichimoku conversion lookback) + Lowest(low, Ichimoku conversion lookback) + Highest(high, Ichimoku base lookback) + Lowest(low, Ichimoku base lookback)) / 4
Calculation: Senkou Span B (no forward shift) = (Highest(high, Ichimoku span B lookback) + Lowest(low, Ichimoku span B lookback)) / 2
Calculation: CVD = running sum of volume * (2 * close - high - low) / (high - low), with the term 0 when high = low
Calculation: Score = ([close > EMA(close, fast EMA lookback)] - [close < EMA(close, fast EMA lookback)]) + ([EMA(close, fast EMA lookback) > EMA(close, mid EMA lookback)] - [EMA(close, fast EMA lookback) < EMA(close, mid EMA lookback)]) + ([EMA(close, mid EMA lookback) > EMA(close, slow EMA lookback)] - [EMA(close, mid EMA lookback) < EMA(close, slow EMA lookback)]) + ([MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0] - [MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) < 0]) + ([RSI(close, RSI lookback) >= RSI bull threshold] - [RSI(close, RSI lookback) <= RSI bear threshold]) + ([SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor) = up] - [SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor) = down]) + ([close > MAX(Senkou Span A, Senkou Span B)] - [close < MIN(Senkou Span A, Senkou Span B)]) + [volume > 0] * ([CVD > CVD[CVD lookback] AND close > close[CVD lookback]] - [CVD < CVD[CVD lookback] AND close < close[CVD lookback]]), where [c] is 1 if condition c holds and 0 otherwise
Calculation: Aligned bull (chart bars) = (NOT T1 shown OR Score(T1, last completed bar) >= bull verdict threshold) AND (NOT T2 shown OR Score(T2, last completed bar) >= bull verdict threshold) AND (NOT T3 shown OR Score(T3, last completed bar) >= bull verdict threshold) AND (NOT T4 shown OR Score(T4, last completed bar) >= bull verdict threshold)
Calculation: Aligned bear (chart bars) = (NOT T1 shown OR Score(T1, last completed bar) <= bear verdict threshold) AND (NOT T2 shown OR Score(T2, last completed bar) <= bear verdict threshold) AND (NOT T3 shown OR Score(T3, last completed bar) <= bear verdict threshold) AND (NOT T4 shown OR Score(T4, last completed bar) <= bear verdict threshold)
Long: close(T1, last completed bar) > EMA(close, fast EMA lookback, T1, last completed bar)
Short: close(T1, last completed bar) < EMA(close, fast EMA lookback, T1, last completed bar)
Long: EMA(close, fast EMA lookback, T1, last completed bar) > EMA(close, mid EMA lookback, T1, last completed bar)
Short: EMA(close, fast EMA lookback, T1, last completed bar) < EMA(close, mid EMA lookback, T1, last completed bar)
Long: EMA(close, mid EMA lookback, T1, last completed bar) > EMA(close, slow EMA lookback, T1, last completed bar)
Short: EMA(close, mid EMA lookback, T1, last completed bar) < EMA(close, slow EMA lookback, T1, last completed bar)
Long: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T1, last completed bar) > 0
Short: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T1, last completed bar) < 0
Long: RSI(close, RSI lookback, T1, last completed bar) >= RSI bull threshold
Short: RSI(close, RSI lookback, T1, last completed bar) <= RSI bear threshold
Long: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T1, last completed bar) = up
Short: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T1, last completed bar) = down
Long: close(T1, last completed bar) > MAX(Senkou Span A(T1, last completed bar), Senkou Span B(T1, last completed bar))
Short: close(T1, last completed bar) < MIN(Senkou Span A(T1, last completed bar), Senkou Span B(T1, last completed bar))
Long: CVD(T1, last completed bar) > CVD(T1, last completed bar)[CVD lookback] AND close(T1, last completed bar) > close(T1, last completed bar)[CVD lookback]
Short: CVD(T1, last completed bar) < CVD(T1, last completed bar)[CVD lookback] AND close(T1, last completed bar) < close(T1, last completed bar)[CVD lookback]
Long: ADX(ADX lookback, T1, last completed bar) >= ADX threshold AND +DI(ADX lookback, T1, last completed bar) > -DI(ADX lookback, T1, last completed bar)
Short: ADX(ADX lookback, T1, last completed bar) >= ADX threshold AND +DI(ADX lookback, T1, last completed bar) <= -DI(ADX lookback, T1, last completed bar)
Long: close(T1, last completed bar) <= Lowest(close, OBV divergence window, T1, last completed bar) AND OBV(T1, last completed bar) > Lowest(OBV, OBV divergence window, T1, last completed bar)
Short: close(T1, last completed bar) >= Highest(close, OBV divergence window, T1, last completed bar) AND OBV(T1, last completed bar) < Highest(OBV, OBV divergence window, T1, last completed bar)
Long: close(T1, last completed bar) <= Lowest(close, RSI divergence window, T1, last completed bar) AND RSI(close, RSI lookback, T1, last completed bar) > Lowest(RSI(close, RSI lookback), RSI divergence window, T1, last completed bar)
Short: close(T1, last completed bar) >= Highest(close, RSI divergence window, T1, last completed bar) AND RSI(close, RSI lookback, T1, last completed bar) < Highest(RSI(close, RSI lookback), RSI divergence window, T1, last completed bar)
Long: Structure(pivot window, break confirmation, T1, last completed bar) = +1
Short: Structure(pivot window, break confirmation, T1, last completed bar) = -1
Long: Score(T1, last completed bar) >= bull verdict threshold
Short: Score(T1, last completed bar) <= bear verdict threshold
Long: Score(T1, last completed bar) crosses above bull cross level
Short: Score(T1, last completed bar) crosses below bear cross level
Long: close(T2, last completed bar) > EMA(close, fast EMA lookback, T2, last completed bar)
Short: close(T2, last completed bar) < EMA(close, fast EMA lookback, T2, last completed bar)
Long: EMA(close, fast EMA lookback, T2, last completed bar) > EMA(close, mid EMA lookback, T2, last completed bar)
Short: EMA(close, fast EMA lookback, T2, last completed bar) < EMA(close, mid EMA lookback, T2, last completed bar)
Long: EMA(close, mid EMA lookback, T2, last completed bar) > EMA(close, slow EMA lookback, T2, last completed bar)
Short: EMA(close, mid EMA lookback, T2, last completed bar) < EMA(close, slow EMA lookback, T2, last completed bar)
Long: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T2, last completed bar) > 0
Short: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T2, last completed bar) < 0
Long: RSI(close, RSI lookback, T2, last completed bar) >= RSI bull threshold
Short: RSI(close, RSI lookback, T2, last completed bar) <= RSI bear threshold
Long: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T2, last completed bar) = up
Short: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T2, last completed bar) = down
Long: close(T2, last completed bar) > MAX(Senkou Span A(T2, last completed bar), Senkou Span B(T2, last completed bar))
Short: close(T2, last completed bar) < MIN(Senkou Span A(T2, last completed bar), Senkou Span B(T2, last completed bar))
Long: CVD(T2, last completed bar) > CVD(T2, last completed bar)[CVD lookback] AND close(T2, last completed bar) > close(T2, last completed bar)[CVD lookback]
Short: CVD(T2, last completed bar) < CVD(T2, last completed bar)[CVD lookback] AND close(T2, last completed bar) < close(T2, last completed bar)[CVD lookback]
Long: ADX(ADX lookback, T2, last completed bar) >= ADX threshold AND +DI(ADX lookback, T2, last completed bar) > -DI(ADX lookback, T2, last completed bar)
Short: ADX(ADX lookback, T2, last completed bar) >= ADX threshold AND +DI(ADX lookback, T2, last completed bar) <= -DI(ADX lookback, T2, last completed bar)
Long: close(T2, last completed bar) <= Lowest(close, OBV divergence window, T2, last completed bar) AND OBV(T2, last completed bar) > Lowest(OBV, OBV divergence window, T2, last completed bar)
Short: close(T2, last completed bar) >= Highest(close, OBV divergence window, T2, last completed bar) AND OBV(T2, last completed bar) < Highest(OBV, OBV divergence window, T2, last completed bar)
Long: close(T2, last completed bar) <= Lowest(close, RSI divergence window, T2, last completed bar) AND RSI(close, RSI lookback, T2, last completed bar) > Lowest(RSI(close, RSI lookback), RSI divergence window, T2, last completed bar)
Short: close(T2, last completed bar) >= Highest(close, RSI divergence window, T2, last completed bar) AND RSI(close, RSI lookback, T2, last completed bar) < Highest(RSI(close, RSI lookback), RSI divergence window, T2, last completed bar)
Long: Structure(pivot window, break confirmation, T2, last completed bar) = +1
Short: Structure(pivot window, break confirmation, T2, last completed bar) = -1
Long: Score(T2, last completed bar) >= bull verdict threshold
Short: Score(T2, last completed bar) <= bear verdict threshold
Long: Score(T2, last completed bar) crosses above bull cross level
Short: Score(T2, last completed bar) crosses below bear cross level
Long: close(T3, last completed bar) > EMA(close, fast EMA lookback, T3, last completed bar)
Short: close(T3, last completed bar) < EMA(close, fast EMA lookback, T3, last completed bar)
Long: EMA(close, fast EMA lookback, T3, last completed bar) > EMA(close, mid EMA lookback, T3, last completed bar)
Short: EMA(close, fast EMA lookback, T3, last completed bar) < EMA(close, mid EMA lookback, T3, last completed bar)
Long: EMA(close, mid EMA lookback, T3, last completed bar) > EMA(close, slow EMA lookback, T3, last completed bar)
Short: EMA(close, mid EMA lookback, T3, last completed bar) < EMA(close, slow EMA lookback, T3, last completed bar)
Long: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T3, last completed bar) > 0
Short: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T3, last completed bar) < 0
Long: RSI(close, RSI lookback, T3, last completed bar) >= RSI bull threshold
Short: RSI(close, RSI lookback, T3, last completed bar) <= RSI bear threshold
Long: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T3, last completed bar) = up
Short: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T3, last completed bar) = down
Long: close(T3, last completed bar) > MAX(Senkou Span A(T3, last completed bar), Senkou Span B(T3, last completed bar))
Short: close(T3, last completed bar) < MIN(Senkou Span A(T3, last completed bar), Senkou Span B(T3, last completed bar))
Long: CVD(T3, last completed bar) > CVD(T3, last completed bar)[CVD lookback] AND close(T3, last completed bar) > close(T3, last completed bar)[CVD lookback]
Short: CVD(T3, last completed bar) < CVD(T3, last completed bar)[CVD lookback] AND close(T3, last completed bar) < close(T3, last completed bar)[CVD lookback]
Long: ADX(ADX lookback, T3, last completed bar) >= ADX threshold AND +DI(ADX lookback, T3, last completed bar) > -DI(ADX lookback, T3, last completed bar)
Short: ADX(ADX lookback, T3, last completed bar) >= ADX threshold AND +DI(ADX lookback, T3, last completed bar) <= -DI(ADX lookback, T3, last completed bar)
Long: close(T3, last completed bar) <= Lowest(close, OBV divergence window, T3, last completed bar) AND OBV(T3, last completed bar) > Lowest(OBV, OBV divergence window, T3, last completed bar)
Short: close(T3, last completed bar) >= Highest(close, OBV divergence window, T3, last completed bar) AND OBV(T3, last completed bar) < Highest(OBV, OBV divergence window, T3, last completed bar)
Long: close(T3, last completed bar) <= Lowest(close, RSI divergence window, T3, last completed bar) AND RSI(close, RSI lookback, T3, last completed bar) > Lowest(RSI(close, RSI lookback), RSI divergence window, T3, last completed bar)
Short: close(T3, last completed bar) >= Highest(close, RSI divergence window, T3, last completed bar) AND RSI(close, RSI lookback, T3, last completed bar) < Highest(RSI(close, RSI lookback), RSI divergence window, T3, last completed bar)
Long: Structure(pivot window, break confirmation, T3, last completed bar) = +1
Short: Structure(pivot window, break confirmation, T3, last completed bar) = -1
Long: Score(T3, last completed bar) >= bull verdict threshold
Short: Score(T3, last completed bar) <= bear verdict threshold
Long: Score(T3, last completed bar) crosses above bull cross level
Short: Score(T3, last completed bar) crosses below bear cross level
Long: close(T4, last completed bar) > EMA(close, fast EMA lookback, T4, last completed bar)
Short: close(T4, last completed bar) < EMA(close, fast EMA lookback, T4, last completed bar)
Long: EMA(close, fast EMA lookback, T4, last completed bar) > EMA(close, mid EMA lookback, T4, last completed bar)
Short: EMA(close, fast EMA lookback, T4, last completed bar) < EMA(close, mid EMA lookback, T4, last completed bar)
Long: EMA(close, mid EMA lookback, T4, last completed bar) > EMA(close, slow EMA lookback, T4, last completed bar)
Short: EMA(close, mid EMA lookback, T4, last completed bar) < EMA(close, slow EMA lookback, T4, last completed bar)
Long: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T4, last completed bar) > 0
Short: MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback, T4, last completed bar) < 0
Long: RSI(close, RSI lookback, T4, last completed bar) >= RSI bull threshold
Short: RSI(close, RSI lookback, T4, last completed bar) <= RSI bear threshold
Long: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T4, last completed bar) = up
Short: SuperTrend direction(SuperTrend ATR lookback, SuperTrend factor, T4, last completed bar) = down
Long: close(T4, last completed bar) > MAX(Senkou Span A(T4, last completed bar), Senkou Span B(T4, last completed bar))
Short: close(T4, last completed bar) < MIN(Senkou Span A(T4, last completed bar), Senkou Span B(T4, last completed bar))
Long: CVD(T4, last completed bar) > CVD(T4, last completed bar)[CVD lookback] AND close(T4, last completed bar) > close(T4, last completed bar)[CVD lookback]
Short: CVD(T4, last completed bar) < CVD(T4, last completed bar)[CVD lookback] AND close(T4, last completed bar) < close(T4, last completed bar)[CVD lookback]
Long: ADX(ADX lookback, T4, last completed bar) >= ADX threshold AND +DI(ADX lookback, T4, last completed bar) > -DI(ADX lookback, T4, last completed bar)
Short: ADX(ADX lookback, T4, last completed bar) >= ADX threshold AND +DI(ADX lookback, T4, last completed bar) <= -DI(ADX lookback, T4, last completed bar)
Long: close(T4, last completed bar) <= Lowest(close, OBV divergence window, T4, last completed bar) AND OBV(T4, last completed bar) > Lowest(OBV, OBV divergence window, T4, last completed bar)
Short: close(T4, last completed bar) >= Highest(close, OBV divergence window, T4, last completed bar) AND OBV(T4, last completed bar) < Highest(OBV, OBV divergence window, T4, last completed bar)
Long: close(T4, last completed bar) <= Lowest(close, RSI divergence window, T4, last completed bar) AND RSI(close, RSI lookback, T4, last completed bar) > Lowest(RSI(close, RSI lookback), RSI divergence window, T4, last completed bar)
Short: close(T4, last completed bar) >= Highest(close, RSI divergence window, T4, last completed bar) AND RSI(close, RSI lookback, T4, last completed bar) < Highest(RSI(close, RSI lookback), RSI divergence window, T4, last completed bar)
Long: Structure(pivot window, break confirmation, T4, last completed bar) = +1
Short: Structure(pivot window, break confirmation, T4, last completed bar) = -1
Long: Score(T4, last completed bar) >= bull verdict threshold
Short: Score(T4, last completed bar) <= bear verdict threshold
Long: Score(T4, last completed bar) crosses above bull cross level
Short: Score(T4, last completed bar) crosses below bear cross level
Long: Aligned bull = TRUE AND Aligned bull[1] = FALSE
Short: Aligned bear = TRUE AND Aligned bear[1] = FALSE