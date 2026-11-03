Calculation: EMA = exponential moving average of close; ATR = average true range.
Calculation: Strong bull bar = close > open, body / (high − low) ≥ strong-bar-body threshold, and upper tail / (high − low) ≤ maximum-entry-tail threshold; strong bear bar is the inverse with lower tail.
Calculation: Bull reversal bar = close > open, close in upper 40% of range, and (strong bull bar or lower tail ≥ 30% of range or close > prior high); bear reversal bar is the inverse.
Calculation: Trend up = EMA rising over the trend lookback, close change over that lookback ≥ minimum ATR-scaled trend move, enough closes above EMA, and directional efficiency ≥ minimum; trend down is the inverse. Strong trend adds close on the trend side of EMA and a strong bar in the trend direction.
Calculation: Range context = prior range width ≤ maximum ATR-scaled width, bar overlap rate ≥ minimum, and directional efficiency ≤ maximum; suppress for the configured bars after a strong breakout bar closes beyond the prior range.
Calculation: Wide channel up/down = corresponding trend and prior range width ≥ minimum ATR-scaled width and overlap rate ≥ minimum.
Calculation: Always-in long/short = corresponding trend, close on the trend side of EMA, not range context, and trend move or frequency of strong trend bars meets its threshold.
Calculation: Bar overlap = current bar range intersects the prior bar range; overlap rate = its moving average over the range lookback. Directional efficiency = absolute close change over the trend lookback divided by high-low span over that lookback.
Calculation: Prior range high/low = highest high / lowest low over the range lookback, excluding the current bar. Range extremes and key levels are touched when the bar range is within an ATR-scaled buffer; key levels are prior-session high, low, close, current-session open, prior range high/low, and EMA.
Calculation: Two-leg down = current low < low two bars ago and prior high > high two bars ago; two-leg up is the inverse.
Calculation: Confirmed pivot high/low = local high/low with the configured number of bars on each side. Double bottom/top = latest two same-side pivots within an ATR-scaled tolerance; descending/ascending wedge = latest three lows descending/highs ascending; head-and-shoulders bottom/top = middle of latest three same-side pivots lower/higher than the others and outer pivots within tolerance.
Calculation: Strong countertrend streak = consecutive strong bars against the trend; countertrend streak = consecutive bars against the trend. Three countertrend bars = three consecutive bars against the trend.
Calculation: Impulse midpoint = midpoint of the highest high and lowest low over the impulse lookback.
Calculation: First breakout = close beyond prior range high/low, open at or inside that boundary, body percentage above the strong-body threshold, and range width ≥ minimum ATR-scaled width. True breakout additionally requires a strong bar and not a doji. Break-fail-break state: after a first breakout, wait for a close back across its boundary, then within the maximum window for a strong bar to close back beyond that same boundary.
Calculation: Trapped-pullback state: after a true breakout, the immediately following bar must be strong in the breakout direction, close farther in that direction, and not be a doji; then, within the maximum window and before a prior trapped-pullback signal, a bar must touch the breakout level within the key buffer, close beyond it in the breakout direction, and not be a doji.
Calculation: Bull/bear structure ready = a corresponding double, wedge, or head-and-shoulders pivot structure formed within the confirmation window. Inside/outside bar = current bar is fully inside / exceeds both prior high and low.
Calculation: Strong trend follow-through extreme = low of the latest strong bull bar during always-in long / high of the latest strong bear bar during always-in short.
Long: Active session AND prior-bar trend up AND not wide channel up AND two-leg down AND current bar bull AND no strong bear bar in the last four bars.
Short: Active session AND prior-bar trend down AND not wide channel down AND two-leg up AND current bar bear AND no strong bull bar in the last four bars.
Long: Active session AND first-breakout state has failed back below its boundary AND, within the maximum window, a strong bull bar closes above that boundary.
Short: Active session AND first-breakout state has failed back above its boundary AND, within the maximum window, a strong bear bar closes below that boundary.
Long: Active session AND bar touches a key level AND (a bull structure is ready and current bar is strong bull or bull reversal and closes above prior high, OR prior bar is inside/outside and current bar is a bull reversal closing above prior high).
Short: Active session AND bar touches a key level AND (a bear structure is ready and current bar is strong bear or bear reversal and closes below prior low, OR prior bar is inside/outside and current bar is a bear reversal closing below prior low).
Long: Active session AND range context AND low ≤ prior range low + key buffer AND (bull reversal bar OR close > prior range low).
Short: Active session AND range context AND high ≥ prior range high − key buffer AND (bear reversal bar OR close < prior range high).
Long: Active session AND prior-bar wide channel down AND descending-wedge structure forms at a confirmed pivot low AND bar touches a key level.
Short: Active session AND prior-bar wide channel up AND ascending-wedge structure forms at a confirmed pivot high AND bar touches a key level.
Long: Active session AND trend up AND not range context AND bar touches impulse midpoint within key buffer AND (two-leg down OR countertrend streak ≤ 3 and strong countertrend streak < 3) AND strong countertrend streak < 3.
Short: Active session AND trend down AND not range context AND bar touches impulse midpoint within key buffer AND (two-leg up OR countertrend streak ≤ 3 and strong countertrend streak < 3) AND strong countertrend streak < 3.
Long: Active session AND true-breakout long state AND follow-through confirmed AND unused pullback signal AND bar touches breakout level within key buffer AND close > breakout level AND not a doji.
Short: Active session AND true-breakout short state AND follow-through confirmed AND unused pullback signal AND bar touches breakout level within key buffer AND close < breakout level AND not a doji.
Long: Active session AND always-in long AND a later bar reaches or passes the latest strong bull follow-through low, closes above it, and fewer than three consecutive bear bars.
Short: Active session AND always-in short AND a later bar reaches or passes the latest strong bear follow-through high, closes below it, and fewer than three consecutive bull bars.
Long: Active session AND prior-bar always-in long AND current and prior bars bear AND the bar two bars ago was not bear.
Short: Active session AND prior-bar always-in short AND current and prior bars bull AND the bar two bars ago was not bull.
Long: Active session AND always-in-long state AND first EMA pullback not yet used in that state AND low ≤ EMA + EMA buffer AND close ≥ EMA − EMA buffer AND current bar is not strong bear.
Short: Active session AND always-in-short state AND first EMA pullback not yet used in that state AND high ≥ EMA − EMA buffer AND close ≤ EMA + EMA buffer AND current bar is not strong bull.
Long: Active session AND always-in long AND current bar bull AND close in upper half of range AND body percentage ≥ strong-body threshold.
Short: Active session AND always-in short AND current bar bear AND close in lower half of range AND body percentage ≥ strong-body threshold.
Exit: Long, prior-bar trend up AND current bar strong bear AND close < impulse midpoint.
Exit: Short, prior-bar trend down AND current bar strong bull AND close > impulse midpoint.
Exit: Long, true-breakout long state with follow-through confirmed AND strong bear bar closes below breakout level.
Exit: Short, true-breakout short state with follow-through confirmed AND strong bull bar closes above breakout level.
Exit: Long, prior bar strong bear and closed below EMA AND current bar bear, closes below EMA, and closes below prior close.
Exit: Short, prior bar strong bull and closed above EMA AND current bar bull, closes above EMA, and closes above prior close.
Exit: Long, trend up or always-in long AND three consecutive bear bars.
Exit: Short, trend down or always-in short AND three consecutive bull bars.