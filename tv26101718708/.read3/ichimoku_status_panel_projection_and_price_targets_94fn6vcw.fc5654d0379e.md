Calculation: Ichimoku source high = close in close-only source mode, otherwise high
Calculation: Ichimoku source low = close in close-only source mode, otherwise low
Calculation: Tenkan-sen = (highest(Ichimoku source high, short lookback) + lowest(Ichimoku source low, short lookback)) / 2
Calculation: Kijun-sen = (highest(Ichimoku source high, middle lookback) + lowest(Ichimoku source low, middle lookback)) / 2
Calculation: Leading Span A = average(Tenkan-sen, Kijun-sen)
Calculation: Leading Span B = (highest(Ichimoku source high, long lookback) + lowest(Ichimoku source low, long lookback)) / 2
Calculation: Effective displacement = max(displacement minus one when the current bar counts as period one, otherwise displacement, one)
Calculation: Current cloud upper boundary = max(Leading Span A[effective displacement], Leading Span B[effective displacement])
Calculation: Current cloud lower boundary = min(Leading Span A[effective displacement], Leading Span B[effective displacement])
Calculation: Lagged cloud upper boundary = max(Leading Span A[2 × effective displacement], Leading Span B[2 × effective displacement])
Calculation: Lagged cloud lower boundary = min(Leading Span A[2 × effective displacement], Leading Span B[2 × effective displacement])
Calculation: Candle color = doji when high equals low or abs(close - open) <= (high - low) × doji ratio; otherwise bullish when close > open and bearish when close < open
Calculation: Kata-fu direction = the most recent non-doji candle color within the direction-search lookback, or neutral if none
Calculation: Kata-fu streak length = bars counted backward from the current bar through candles matching Kata-fu direction or doji, stopping at an opposite-color candle and capped by the streak-scan limit; zero if direction is neutral
Calculation: Kata-fu tier = the greatest of the three ordered streak thresholds reached by Kata-fu streak length, or zero
Calculation: Orderly bullish streak = from oldest to newest, every successive non-doji candle in the streak has a strictly higher high, low, open, and close
Calculation: Orderly bearish streak = from oldest to newest, every successive non-doji candle in the streak has a strictly lower high, low, open, and close
Calculation: Bullish interposed pattern = one of three separately parameterized windows has bullish first and last candles and exactly its configured number of interior candles whose color is not bullish; dojis count as nonmatching
Calculation: Bearish interposed pattern = one of three separately parameterized windows has bearish first and last candles and exactly its configured number of interior candles whose color is not bearish; dojis count as nonmatching
Calculation: Interposed window length = the longest matching bullish or bearish interposed window, or zero
Calculation: Swing-pivot sequence = alternating confirmed pivot highs and lows of the Ichimoku source, using the swing-sensitivity lookback on each side; a same-type latest pivot is replaced only by a more extreme pivot
Calculation: Selected wave = latest three alternating swing pivots unless latest-only mode is selected, or latest-valid mode finds the latest wave unbroken, the preceding wave unavailable, or the preceding wave broken; otherwise use the preceding three pivots. A wave is upward when C is a pivot low and downward when C is a pivot high; its A is broken when close is below A for an upward wave or above A for a downward wave
Long: close > Tenkan-sen
Short: close < Tenkan-sen
Long: close > Kijun-sen
Short: close < Kijun-sen
Long: Tenkan-sen > Kijun-sen
Short: Tenkan-sen < Kijun-sen
Long: close > close[effective displacement]
Short: close < close[effective displacement]
Long: close > Lagged cloud upper boundary
Short: close < Lagged cloud lower boundary
Long: close > Current cloud upper boundary
Short: close < Current cloud lower boundary
Long: Kijun-sen > Kijun-sen[1]
Short: Kijun-sen < Kijun-sen[1]
Long: (Tenkan-sen > Kijun-sen OR (Tenkan-sen = Kijun-sen AND Kijun-sen > Kijun-sen[1])) AND Kijun-sen >= Kijun-sen[1] AND close > close[effective displacement] AND close > Current cloud upper boundary
Short: (Tenkan-sen < Kijun-sen OR (Tenkan-sen = Kijun-sen AND Kijun-sen < Kijun-sen[1])) AND Kijun-sen <= Kijun-sen[1] AND close < close[effective displacement] AND close < Current cloud lower boundary
Long: Kata-fu direction is bullish AND Kata-fu streak length >= the lowest streak threshold
Short: Kata-fu direction is bearish AND Kata-fu streak length >= the lowest streak threshold
Long: Bullish interposed pattern
Short: Bearish interposed pattern
Long: A selected wave exists AND selected wave C is a pivot low
Short: A selected wave exists AND selected wave C is a pivot high
Long: bullish alerts enabled AND Kata-fu direction is bullish AND Kata-fu tier > Kata-fu tier[1] AND Kata-fu tier >= selected minimum alert tier AND (orderly-only disabled OR Orderly bullish streak) AND (prior-opposite-move-only disabled OR close[Kata-fu streak length - 1 + effective displacement] > close[Kata-fu streak length - 1])
Short: bearish alerts enabled AND Kata-fu direction is bearish AND Kata-fu tier > Kata-fu tier[1] AND Kata-fu tier >= selected minimum alert tier AND (orderly-only disabled OR Orderly bearish streak) AND (prior-opposite-move-only disabled OR close[Kata-fu streak length - 1 + effective displacement] < close[Kata-fu streak length - 1])
Long: interposed alerts enabled AND bullish alerts enabled AND Bullish interposed pattern AND Interposed window length > 0 AND Interposed window length != Interposed window length[1] AND (prior-opposite-move-only disabled OR close[Interposed window length - 1 + effective displacement] > close[Interposed window length - 1])
Short: interposed alerts enabled AND bearish alerts enabled AND Bearish interposed pattern AND Interposed window length > 0 AND Interposed window length != Interposed window length[1] AND (prior-opposite-move-only disabled OR close[Interposed window length - 1 + effective displacement] < close[Interposed window length - 1])