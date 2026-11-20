Calculation: Latest swing high = most recently confirmed PivotHigh(high, pivot lookback on each side)
Calculation: Latest swing low = most recently confirmed PivotLow(low, pivot lookback on each side)
Calculation: Structure direction = bullish after the latest confirmed upward swing break, bearish after the latest confirmed downward swing break, and neutral before either
Calculation: Higher-timeframe trend(T) = bullish when EMA(close, shorter lookback, T, last completed bar) > EMA(close, longer lookback, T, last completed bar) AND close(T, last completed bar) > EMA(close, longer lookback, T, last completed bar); bearish when both comparisons are reversed; otherwise neutral; evaluated on chart bars using T values, with T1 > T2 > T3
Calculation: Bullish retest zone = the latest upward break level ± ATR(ATR lookback at break bar) × zone half-height parameter; active until retested, closed below its lower boundary, an opposite break, or expiry
Calculation: Bearish retest zone = the latest downward break level ± ATR(ATR lookback at break bar) × zone half-height parameter; active until retested, closed above its upper boundary, an opposite break, or expiry
Calculation: Session high = highest high of chart bars in the latest configured session
Calculation: Session low = lowest low of chart bars in the latest configured session
Long: PivotHigh(high, pivot lookback on each side) > previous confirmed PivotHigh(high, same lookback)
Long: PivotLow(low, pivot lookback on each side) > previous confirmed PivotLow(low, same lookback)
Short: PivotHigh(high, pivot lookback on each side) < previous confirmed PivotHigh(high, same lookback)
Short: PivotLow(low, pivot lookback on each side) < previous confirmed PivotLow(low, same lookback)
Long: On a confirmed chart bar, close > latest swing high AND that swing has not already been closed through since confirmation
Short: On a confirmed chart bar, close < latest swing low AND that swing has not already been closed through since confirmation
Long: On a confirmed chart bar later than an upward break, an active bullish retest zone exists AND low <= its upper boundary AND close > open AND close > its upper boundary
Short: On a confirmed chart bar later than a downward break, an active bearish retest zone exists AND high >= its lower boundary AND close < open AND close < its lower boundary
Long: On an intraday chart bar confirmed at close, low < low(T1, last completed bar) AND close > low(T1, last completed bar) AND this level has not already been swept in the current T1 period
Short: On an intraday chart bar confirmed at close, high > high(T1, last completed bar) AND close < high(T1, last completed bar) AND this level has not already been swept in the current T1 period
Long: On a confirmed chart bar outside the configured session, with chart timeframe <= T3, low < Session low AND close > Session low AND this level has not already been swept in the current session
Short: On a confirmed chart bar outside the configured session, with chart timeframe <= T3, high > Session high AND close < Session high AND this level has not already been swept in the current session
Long: On a confirmed chart bar, low > high[2] AND low - high[2] >= ATR(ATR lookback) × minimum gap ATR multiple
Short: On a confirmed chart bar, high < low[2] AND low[2] - high >= ATR(ATR lookback) × minimum gap ATR multiple
Long: Structure direction is bullish
Short: Structure direction is bearish
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)
Long: close > EMA(close, longest lookback)
Short: close < EMA(close, longest lookback)
Long: On chart bars with chart timeframe <= T1, Higher-timeframe trend(T1) is bullish
Short: On chart bars with chart timeframe <= T1, Higher-timeframe trend(T1) is bearish
Long: On chart bars with chart timeframe <= T2, Higher-timeframe trend(T2) is bullish
Short: On chart bars with chart timeframe <= T2, Higher-timeframe trend(T2) is bearish
Long: On chart bars with chart timeframe <= T3, Higher-timeframe trend(T3) is bullish
Short: On chart bars with chart timeframe <= T3, Higher-timeframe trend(T3) is bearish