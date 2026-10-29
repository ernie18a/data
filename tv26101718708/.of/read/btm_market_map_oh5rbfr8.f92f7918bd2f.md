Calculation: Confirmed swing high/low = a bar whose high/low is respectively higher/lower than the configured number of bars on both sides; confirm after the right-side bars complete.
Calculation: Higher high / lower high = confirmed swing high above / below the preceding confirmed swing high; higher low / lower low = confirmed swing low above / below the preceding confirmed swing low.
Calculation: Bull zone = the latest higher low ± configured ATR multiple, set on a bullish BOS or on a new higher low during bullish flow with a fresh higher high; expires after the configured number of bars.
Calculation: Bear zone = the latest lower high ± configured ATR multiple, set on a bearish BOS or on a new lower high during bearish flow with a fresh lower low; expires after the configured number of bars.
Calculation: Equal high/low level = the higher/lower of two consecutive confirmed swing highs/lows whose difference is no greater than the configured tolerance times ATR; discard the level after a sweep or close through it.
Long: bearish structure state AND close > latest lower high (bullish CHOCH)
Long: bullish CHOCH state AND close > latest higher high (bullish BOS)
Long: current bar overlaps the active bull zone AND the zone has not previously been touched
Long: low < previous day low AND close > previous day low AND this level has not been swept today
Long: during the configured London session, low < Asian session low AND close > Asian session low AND this level has not been swept today
Long: during the configured New York window, low < London session low AND close > London session low AND this level has not been swept today
Long: low < equal low level AND close > equal low level
Short: bullish structure state AND close < latest higher low (bearish CHOCH)
Short: bearish CHOCH state AND close < latest lower low (bearish BOS)
Short: current bar overlaps the active bear zone AND the zone has not previously been touched
Short: high > previous day high AND close < previous day high AND this level has not been swept today
Short: during the configured London session, high > Asian session high AND close < Asian session high AND this level has not been swept today
Short: during the configured New York window, high > London session high AND close < London session high AND this level has not been swept today
Short: high > equal high level AND close < equal high level