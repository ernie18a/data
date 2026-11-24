Calculation: Bar range = max(high - low, minimum tick)
Calculation: Body fraction = abs(close - open) / bar range
Calculation: Strong bull bar = close > open AND body fraction >= strong-body fraction threshold AND high - max(open, close) <= bar range * entry-tail fraction threshold
Calculation: Strong bear bar = close < open AND body fraction >= strong-body fraction threshold AND min(open, close) - low <= bar range * entry-tail fraction threshold
Calculation: Doji = body fraction <= doji-body fraction threshold
Calculation: Bull reversal bar = close > open AND close >= low + bar range * bull-close-position threshold AND (strong bull bar OR min(open, close) - low >= bar range * reversal-tail threshold OR close > high[1])
Calculation: Bear reversal bar = close < open AND close <= high - bar range * bear-close-position threshold AND (strong bear bar OR high - max(open, close) >= bar range * reversal-tail threshold OR close < low[1])
Calculation: Active bar = true unless the session filter is enabled, when the bar must be inside the configured session; session levels reset at session start, or at a new calendar day when the filter is disabled
Calculation: Range high = highest(high[1], range lookback)
Calculation: Range low = lowest(low[1], range lookback)
Calculation: Range width = max(range high - range low, minimum tick)
Calculation: Overlap fraction = SMA(1 when high >= low[1] AND low <= high[1], range lookback)
Calculation: Range efficiency = abs(close - close[range lookback]) / max(highest(high, range lookback) - lowest(low, range lookback), minimum tick)
Calculation: Trend up = (EMA(close, EMA length) - EMA(close, EMA length)[trend lookback]) / max(ATR(ATR length), minimum tick) > 0 AND (close - close[trend lookback]) / max(ATR(ATR length), minimum tick) >= minimum trend move in ATR AND SMA(1 when close > EMA(close, EMA length), trend lookback) >= minimum trend-side close fraction AND range efficiency >= minimum trend efficiency
Calculation: Trend down = (EMA(close, EMA length) - EMA(close, EMA length)[trend lookback]) / max(ATR(ATR length), minimum tick) < 0 AND (close - close[trend lookback]) / max(ATR(ATR length), minimum tick) <= -minimum trend move in ATR AND SMA(1 when close < EMA(close, EMA length), trend lookback) >= minimum trend-side close fraction AND range efficiency >= minimum trend efficiency
Calculation: Range breakout up = strong bull bar AND bar range >= ATR(ATR length) * breakout-bar size parameter AND close > range high
Calculation: Range breakout down = strong bear bar AND bar range >= ATR(ATR length) * breakout-bar size parameter AND close < range low
Calculation: Range context = range width <= ATR(ATR length) * maximum range width in ATR AND overlap fraction >= minimum range overlap AND range efficiency <= maximum range efficiency AND no range-break state is active; that state is set to the breakout-suppression count on a range breakout and decremented once per following bar until zero
Calculation: Wide channel up = trend up AND range width >= ATR(ATR length) * minimum wide-channel width in ATR AND overlap fraction >= minimum wide-channel overlap
Calculation: Wide channel down = trend down AND range width >= ATR(ATR length) * minimum wide-channel width in ATR AND overlap fraction >= minimum wide-channel overlap
Calculation: Always-in long = trend up AND close > EMA(close, EMA length) AND not range context
Calculation: Always-in short = trend down AND close < EMA(close, EMA length) AND not range context
Calculation: Near key level = the bar's low-high range touches within ATR(ATR length) * key-level distance parameter of previous-session high, low, or close; current-session open; range high or low; EMA(close, EMA length) within its separate EMA-distance parameter; or any enabled manual level
Calculation: First range break up = active bar AND close > range high AND open <= range high AND body fraction >= strong-body fraction threshold AND range width >= ATR(ATR length) * first-break width parameter
Calculation: First range break down = active bar AND close < range low AND open >= range low AND body fraction >= strong-body fraction threshold AND range width >= ATR(ATR length) * first-break width parameter
Calculation: Two-leg down = low < low[pattern lookback offset] AND high[1] > high[pattern lookback offset]
Calculation: Two-leg up = high > high[pattern lookback offset] AND low[1] < low[pattern lookback offset]
Calculation: Bear streak = number of consecutive bear bars ending at the current bar
Calculation: Bull streak = number of consecutive bull bars ending at the current bar
Calculation: Strong bear streak = number of consecutive strong bear bars ending at the current bar
Calculation: Strong bull streak = number of consecutive strong bull bars ending at the current bar
Calculation: Double-bottom structure = a newly confirmed pivot low and the latest two pivot lows are within ATR(ATR length) * double-pivot proximity parameter
Calculation: Double-top structure = a newly confirmed pivot high and the latest two pivot highs are within ATR(ATR length) * double-pivot proximity parameter
Calculation: Down-wedge structure = a newly confirmed pivot low and the latest three pivot lows descend strictly
Calculation: Up-wedge structure = a newly confirmed pivot high and the latest three pivot highs ascend strictly
Calculation: Bottom head-and-shoulders structure = a newly confirmed pivot low, the middle of the latest three pivot lows is below both outer lows, and the outer lows are within ATR(ATR length) * head-and-shoulders proximity parameter
Calculation: Top head-and-shoulders structure = a newly confirmed pivot high, the middle of the latest three pivot highs is above both outer highs, and the outer highs are within ATR(ATR length) * head-and-shoulders proximity parameter
Calculation: Impulse midpoint = (highest(high, impulse lookback) + lowest(low, impulse lookback)) / 2
Calculation: H2 pullback condition = active bar AND trend up[1] AND not wide channel up AND two-leg down AND close > open AND no strong bear bar in the clean-pullback lookback
Calculation: L2 pullback condition = active bar AND trend down[1] AND not wide channel down AND two-leg up AND close < open AND no strong bull bar in the clean-pullback lookback
Long: confirmed bar AND active bar AND H2 pullback condition
Short: confirmed bar AND active bar AND L2 pullback condition
Long: confirmed bar AND a first range break up occurred within the break-fail-break window, a later bar closed below its stored range-high level, and the current bar closes above that level with a strong bull bar
Short: confirmed bar AND a first range break down occurred within the break-fail-break window, a later bar closed above its stored range-low level, and the current bar closes below that level with a strong bear bar
Long: confirmed bar AND active bar AND near key level AND ((a bullish key structure was confirmed within the structure window measured from its newest pivot bar AND (strong bull bar OR bull reversal bar) AND close > high[1]) OR ((high[1] < high[2] AND low[1] > low[2]) OR (high[1] > high[2] AND low[1] < low[2])) AND bull reversal bar AND close > high[1] OR H2 pullback condition AND near key level)
Short: confirmed bar AND active bar AND near key level AND ((a bearish key structure was confirmed within the structure window measured from its newest pivot bar AND (strong bear bar OR bear reversal bar) AND close < low[1]) OR ((high[1] < high[2] AND low[1] > low[2]) OR (high[1] > high[2] AND low[1] < low[2])) AND bear reversal bar AND close < low[1] OR L2 pullback condition AND near key level)
Long: confirmed bar AND active bar AND range context AND low <= range low + ATR(ATR length) * key-level distance parameter AND (bull reversal bar OR close > range low)
Short: confirmed bar AND active bar AND range context AND high >= range high - ATR(ATR length) * key-level distance parameter AND (bear reversal bar OR close < range high)
Long: confirmed bar AND active bar AND wide channel down[pivot strength] AND down-wedge structure AND near key level
Short: confirmed bar AND active bar AND wide channel up[pivot strength] AND up-wedge structure AND near key level
Long: confirmed bar AND active bar AND trend up AND not range context AND the bar touches the impulse midpoint within ATR(ATR length) * key-level distance parameter AND (two-leg down OR bear streak <= countertrend-bar limit) AND strong bear streak < strong-countertrend-bar limit
Short: confirmed bar AND active bar AND trend down AND not range context AND the bar touches the impulse midpoint within ATR(ATR length) * key-level distance parameter AND (two-leg up OR bull streak <= countertrend-bar limit) AND strong bull streak < strong-countertrend-bar limit
Long: confirmed bar AND active bar AND a first range break up had a strong bull bar that was not a doji, the immediately following bar was a strong bull bar that closed above the breakout bar's close and was not a doji, and a later unused bar within the trap window touches the stored range-high level within ATR(ATR length) * key-level distance parameter, closes above it, and is not a doji
Short: confirmed bar AND active bar AND a first range break down had a strong bear bar that was not a doji, the immediately following bar was a strong bear bar that closed below the breakout bar's close and was not a doji, and a later unused bar within the trap window touches the stored range-low level within ATR(ATR length) * key-level distance parameter, closes below it, and is not a doji
Long: confirmed bar AND active bar AND always-in long AND the current bar is later than the most recent prior always-in-long strong-bull bar AND low <= that bar's low AND close > that bar's low AND bear streak is below the forced-exit streak length
Short: confirmed bar AND active bar AND always-in short AND the current bar is later than the most recent prior always-in-short strong-bear bar AND high >= that bar's high AND close < that bar's high AND bull streak is below the forced-exit streak length
Long: confirmed bar AND active bar AND always-in long[1] AND close < open AND close[1] < open[1] AND close[2] >= open[2]
Short: confirmed bar AND active bar AND always-in short[1] AND close > open AND close[1] > open[1] AND close[2] <= open[2]
Long: confirmed bar AND active bar AND the session's always-in state is long, its one-use-per-state pullback has not occurred, low <= EMA(close, EMA length) + ATR(ATR length) * EMA-distance parameter, close >= EMA(close, EMA length) - ATR(ATR length) * EMA-distance parameter, and the bar is not a strong bear bar
Short: confirmed bar AND active bar AND the session's always-in state is short, its one-use-per-state pullback has not occurred, high >= EMA(close, EMA length) - ATR(ATR length) * EMA-distance parameter, close <= EMA(close, EMA length) + ATR(ATR length) * EMA-distance parameter, and the bar is not a strong bull bar
Long: confirmed bar AND active bar AND always-in long AND close > open AND close >= low + bar range * scalp-close-position threshold AND body fraction >= strong-body fraction threshold
Short: confirmed bar AND active bar AND always-in short AND close < open AND close <= high - bar range * scalp-close-position threshold AND body fraction >= strong-body fraction threshold
Long: confirmed bar AND always-in long AND not always-in long[1]
Short: confirmed bar AND always-in short AND not always-in short[1]
Exit: long, confirmed bar AND (trend up[1] AND strong bear bar AND close < impulse midpoint OR a valid trap-long state remains active AND close is below its stored range-high level AND strong bear bar OR strong bear bar[1] AND close[1] < EMA(close, EMA length)[1] AND close < open AND close < EMA(close, EMA length) AND close < close[1] OR trend up AND the bear streak reaches the forced-exit streak length)
Exit: short, confirmed bar AND (trend down[1] AND strong bull bar AND close > impulse midpoint OR a valid trap-short state remains active AND close is above its stored range-low level AND strong bull bar OR strong bull bar[1] AND close[1] > EMA(close, EMA length)[1] AND close > open AND close > EMA(close, EMA length) AND close > close[1] OR trend down AND the bull streak reaches the forced-exit streak length)