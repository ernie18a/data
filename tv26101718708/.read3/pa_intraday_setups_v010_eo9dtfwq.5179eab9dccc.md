Calculation: Bar range = max(high - low, minimum tick)
Calculation: Body fraction = abs(close - open) / bar range
Calculation: Upper tail = high - max(open, close)
Calculation: Lower tail = min(open, close) - low
Calculation: Bull bar = close > open
Calculation: Bear bar = close < open
Calculation: Strong bull bar = bull bar AND body fraction >= strong-body threshold AND upper tail <= bar range * entry-tail limit
Calculation: Strong bear bar = bear bar AND body fraction >= strong-body threshold AND lower tail <= bar range * entry-tail limit
Calculation: Doji = body fraction <= doji-body threshold
Calculation: Bull reversal bar = bull bar AND close >= low + bar range * reversal-close fraction AND (strong bull bar OR lower tail >= bar range * reversal-tail fraction OR close > previous bar high)
Calculation: Bear reversal bar = bear bar AND close <= high - bar range * reversal-close fraction AND (strong bear bar OR upper tail >= bar range * reversal-tail fraction OR close < previous bar low)
Calculation: Active session = session filter is disabled OR current bar is within the configured session
Calculation: Touches(level, tolerance) = low <= level + tolerance AND high >= level - tolerance
Calculation: Prior range high = Highest(high from the previous bar, range lookback)
Calculation: Prior range low = Lowest(low from the previous bar, range lookback)
Calculation: Prior range width = max(prior range high - prior range low, minimum tick)
Calculation: Bar overlap = high >= previous bar low AND low <= previous bar high
Calculation: Range overlap fraction = SMA(1 if bar overlap else 0, range lookback)
Calculation: Range efficiency = abs(close - close[range lookback]) / max(Highest(high, range lookback) - Lowest(low, range lookback), minimum tick)
Calculation: Normalized EMA slope = (EMA(close, EMA lookback) - EMA(close, EMA lookback)[trend lookback]) / max(ATR(ATR lookback), minimum tick)
Calculation: Normalized trend move = (close - close[trend lookback]) / max(ATR(ATR lookback), minimum tick)
Calculation: Trend-side close fraction = SMA(1 if close is on the trend side of EMA(close, EMA lookback) else 0, trend lookback)
Calculation: Uptrend = normalized EMA slope > 0 AND normalized trend move >= minimum trend move AND trend-side close fraction >= minimum trend-side fraction AND range efficiency >= minimum trend efficiency
Calculation: Downtrend = normalized EMA slope < 0 AND normalized trend move <= -minimum trend move AND trend-side close fraction below EMA >= minimum trend-side fraction AND range efficiency >= minimum trend efficiency
Calculation: Balanced range = prior range width <= ATR(ATR lookback) * maximum range-width multiple AND range overlap fraction >= minimum range overlap AND range efficiency <= maximum range efficiency
Calculation: Wide-channel up = uptrend AND prior range width >= ATR(ATR lookback) * minimum wide-channel width multiple AND range overlap fraction >= minimum wide-channel overlap
Calculation: Wide-channel down = downtrend AND prior range width >= ATR(ATR lookback) * minimum wide-channel width multiple AND range overlap fraction >= minimum wide-channel overlap
Calculation: Always-in long = uptrend AND close > EMA(close, EMA lookback) AND NOT balanced range AND (abs(normalized trend move) >= minimum trend move OR SMA(1 if strong bull bar else 0, trend lookback) >= minimum strong-bull fraction)
Calculation: Always-in short = downtrend AND close < EMA(close, EMA lookback) AND NOT balanced range AND (abs(normalized trend move) >= minimum trend move OR SMA(1 if strong bear bar else 0, trend lookback) >= minimum strong-bear fraction)
Calculation: Near key level = the current bar touches a prior-session high, low, or close; current-session open; prior range high or low; an enabled manual level; or EMA(close, EMA lookback), using ATR(ATR lookback) times the key-level proximity threshold for all levels except EMA, which uses the separate EMA proximity threshold
Calculation: Two-leg downward pullback = low < low[longer leg offset] AND high[shorter leg offset] > high[longer leg offset], where the shorter leg offset is less than the longer leg offset
Calculation: Two-leg upward pullback = high > high[longer leg offset] AND low[shorter leg offset] < low[longer leg offset], where the shorter leg offset is less than the longer leg offset
Calculation: Downward wedge = a newly confirmed pivot low is lower than the preceding confirmed pivot low, which is lower than the confirmed pivot low before it
Calculation: Upward wedge = a newly confirmed pivot high is higher than the preceding confirmed pivot high, which is higher than the confirmed pivot high before it
Calculation: Bullish pivot structure = a double bottom within ATR(ATR lookback) times the double-pivot tolerance, downward wedge, or bottom head-and-shoulders whose outer pivot lows are within ATR(ATR lookback) times the head-and-shoulders tolerance
Calculation: Bearish pivot structure = a double top within ATR(ATR lookback) times the double-pivot tolerance, upward wedge, or top head-and-shoulders whose outer pivot highs are within ATR(ATR lookback) times the head-and-shoulders tolerance
Calculation: Bullish structure ready = the most recently recorded bullish pivot structure is after its pivot bar and within the structure-confirmation window
Calculation: Bearish structure ready = the most recently recorded bearish pivot structure is after its pivot bar and within the structure-confirmation window
Calculation: Long H2 setup = active session AND uptrend on the previous bar AND NOT wide-channel up AND two-leg downward pullback AND bull bar AND no strong bear bar within the clean-pullback lookback
Calculation: Short L2 setup = active session AND downtrend on the previous bar AND NOT wide-channel down AND two-leg upward pullback AND bear bar AND no strong bull bar within the clean-pullback lookback
Calculation: Impulse midpoint = (Highest(high, impulse lookback) + Lowest(low, impulse lookback)) / 2
Calculation: Long AI state = switches to long when always-in long becomes active, switches to short when always-in short becomes active, and resets to neutral when neither is active and balanced range is active
Calculation: Short AI state = switches to short when always-in short becomes active, switches to long when always-in long becomes active, and resets to neutral when neither is active and balanced range is active
Long: always-in long AND NOT always-in long on the previous bar
Short: always-in short AND NOT always-in short on the previous bar
Long: wide-channel up AND NOT wide-channel up on the previous bar
Short: wide-channel down AND NOT wide-channel down on the previous bar
Long: long H2 setup
Short: short L2 setup
Long: after an upward breakout where open <= the prior range high, close > that level, body fraction >= strong-body threshold, and prior range width >= ATR(ATR lookback) * minimum breakout-width multiple, a later close fell below that recorded level, and the current later close is above it with a strong bull bar before the break-fail window expires
Short: after a downward breakout where open >= the prior range low, close < that level, body fraction >= strong-body threshold, and prior range width >= ATR(ATR lookback) * minimum breakout-width multiple, a later close rose above that recorded level, and the current later close is below it with a strong bear bar before the break-fail window expires
Long: active session AND near key level AND (bullish structure ready AND (strong bull bar OR bull reversal bar) AND close > previous bar high OR previous bar is inside or outside AND bull reversal bar AND close > previous bar high OR long H2 setup)
Short: active session AND near key level AND (bearish structure ready AND (strong bear bar OR bear reversal bar) AND close < previous bar low OR previous bar is inside or outside AND bear reversal bar AND close < previous bar low OR short L2 setup)
Long: active session AND balanced range AND low <= prior range low + ATR(ATR lookback) * key-level proximity threshold AND (bull reversal bar OR close > prior range low)
Short: active session AND balanced range AND high >= prior range high - ATR(ATR lookback) * key-level proximity threshold AND (bear reversal bar OR close < prior range high)
Long: active session AND wide-channel down on the bar at the pivot-strength offset AND downward wedge AND near key level
Short: active session AND wide-channel up on the bar at the pivot-strength offset AND upward wedge AND near key level
Long: active session AND uptrend AND NOT balanced range AND current bar touches the impulse midpoint within ATR(ATR lookback) * key-level proximity threshold AND (two-leg downward pullback OR BarsSince(not bear bar) <= weak-pullback streak limit) AND BarsSince(not strong bear bar) < strong-countertrend streak limit
Short: active session AND downtrend AND NOT balanced range AND current bar touches the impulse midpoint within ATR(ATR lookback) * key-level proximity threshold AND (two-leg upward pullback OR BarsSince(not bull bar) <= weak-pullback streak limit) AND BarsSince(not strong bull bar) < strong-countertrend streak limit
Long: after an upward breakout satisfying the break-fail breakout conditions, with a strong bull bar and not a doji, the next bar is a strong bull bar that closes above the breakout bar's close and is not a doji; later, before the trap timeout expires and before this setup has been used, the current bar touches the recorded breakout level within ATR(ATR lookback) * key-level proximity threshold, closes above it, and is not a doji
Short: after a downward breakout satisfying the break-fail breakout conditions, with a strong bear bar and not a doji, the next bar is a strong bear bar that closes below the breakout bar's close and is not a doji; later, before the trap timeout expires and before this setup has been used, the current bar touches the recorded breakout level within ATR(ATR lookback) * key-level proximity threshold, closes below it, and is not a doji
Long: active session AND always-in long AND the current bar is later than the most recent earlier always-in-long strong-bull follow-through bar AND low <= that bar's low AND close > that bar's low AND NOT three consecutive bear bars
Short: active session AND always-in short AND the current bar is later than the most recent earlier always-in-short strong-bear follow-through bar AND high >= that bar's high AND close < that bar's high AND NOT three consecutive bull bars
Long: active session AND always-in long on the previous bar AND bear bar now and on the previous bar AND the bar before those was not a bear bar
Short: active session AND always-in short on the previous bar AND bull bar now and on the previous bar AND the bar before those was not a bull bar
Long: active session AND long AI state AND EMA pullback has not been marked in this state AND low <= EMA(close, EMA lookback) + ATR(ATR lookback) * EMA proximity threshold AND close >= EMA(close, EMA lookback) - ATR(ATR lookback) * EMA proximity threshold AND NOT strong bear bar
Short: active session AND short AI state AND EMA pullback has not been marked in this state AND high >= EMA(close, EMA lookback) - ATR(ATR lookback) * EMA proximity threshold AND close <= EMA(close, EMA lookback) + ATR(ATR lookback) * EMA proximity threshold AND NOT strong bull bar
Long: active session AND always-in long AND bull bar AND close >= low + bar range * scalp close-location threshold AND body fraction >= strong-body threshold
Short: active session AND always-in short AND bear bar AND close <= high - bar range * scalp close-location threshold AND body fraction >= strong-body threshold
Exit: long, uptrend OR always-in long AND bearish on the current bar and on the preceding bars spanning the forced-exit streak parameter
Exit: short, downtrend OR always-in short AND bullish on the current bar and on the preceding bars spanning the forced-exit streak parameter
Exit: long, uptrend on the previous bar AND strong bear bar AND close < impulse midpoint
Exit: short, downtrend on the previous bar AND strong bull bar AND close > impulse midpoint
Exit: long, an active long trapped-breakout state with valid follow-through AND before trap timeout AND close < recorded breakout level AND strong bear bar
Exit: short, an active short trapped-breakout state with valid follow-through AND before trap timeout AND close > recorded breakout level AND strong bull bar
Exit: long, strong bear bar on the previous bar AND previous close < previous EMA(close, EMA lookback) AND bear bar now AND close < EMA(close, EMA lookback) AND close < previous close
Exit: short, strong bull bar on the previous bar AND previous close > previous EMA(close, EMA lookback) AND bull bar now AND close > EMA(close, EMA lookback) AND close > previous close