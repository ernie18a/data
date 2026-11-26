Calculation: sellside sweep = this bar is the first bar at or after the first bar with low < L whose close > L, and it lies within the reclaim window of that first bar with low < L, where L is a live sellside level
Calculation: buyside sweep = this bar is the first bar at or after the first bar with high > H whose close < H, and it lies within the reclaim window of that first bar with high > H, where H is a live buyside level
Calculation: eligible sellside sweep = sellside sweep AND signals enabled AND long side allowed AND extension in an enabled band AND penetration in an enabled band AND (session filter disabled OR bar inside an enabled session) AND (weekday filter disabled OR weekday of bar enabled) AND (raid cap disabled OR same-side raid ordinal <= raid cap) AND (bias filter disabled OR bias != -1) AND (zone filter disabled OR zone position <= long zone limit) AND (SMT requirement disabled OR no valid SMT peer OR SMT divergence (long)) AND (session progress filter disabled OR session progress <= progress limit)
Calculation: eligible buyside sweep = buyside sweep AND signals enabled AND short side allowed AND extension in an enabled band AND penetration in an enabled band AND (session filter disabled OR bar inside an enabled session) AND (weekday filter disabled OR weekday of bar enabled) AND (raid cap disabled OR same-side raid ordinal <= raid cap) AND (bias filter disabled OR bias != +1) AND (zone filter disabled OR zone position >= short zone limit) AND (SMT requirement disabled OR no valid SMT peer OR SMT divergence (short)) AND (session progress filter disabled OR session progress <= progress limit)
Calculation: raid extreme = lowest low (sellside sweep) or highest high (buyside sweep) from the first breach bar through the sweep bar
Calculation: extension = max(0, dir * (reference open - raid extreme)) / ATR(length), where reference open is the price selected by the extension reference setting at the sweep bar and dir = +1 for a sellside sweep, -1 for a buyside sweep
Calculation: penetration = |raid extreme - swept level| / ATR(length), where swept level is L for a sellside sweep and H for a buyside sweep
Calculation: initial stop = raid extreme - dir * stop multiple * ATR(length), with ATR taken at the entry bar
Calculation: risk = |entry price - initial stop|
Calculation: stop width ok = minimum stop disabled OR risk >= minimum stop multiple * ATR(length)
Calculation: first target = nearest unbreached level beyond entry on the far side (buyside above a long, sellside below a short) with distance >= minimum R * risk, when the liquidity target is selected and such a level exists; otherwise entry + dir * target R * risk
Calculation: second target = second nearest such level when the liquidity target is selected and it exists; otherwise entry + dir * second target R * risk; if this is not beyond the first target, first target + dir * risk
Calculation: target = first target until a partial exit has been taken, then second target
Calculation: active stop = initial stop, tightened toward profit only (to entry) once a partial exit has been taken, or once breakeven is enabled and best price through the previous bar has reached entry + dir * breakeven R * risk; and, once trailing is enabled and best price through the previous bar has reached entry + dir * trail R * risk, tightened toward profit only to best price through two bars back * (1 - dir * trail %); best price = highest high since entry for long, lowest low since entry for short
Calculation: impulse threshold = 2 * running mean of |(close[1] - open[1]) / open[1]| over all bars so far, or 0 when the auto threshold is off
Calculation: bullish gap = low > high[2] AND close[1] > high[2] AND (close[1] - open[1]) / open[1] > impulse threshold AND low - high[2] >= minimum gap, with top = low and bottom = high[2], where minimum gap = gap multiple * ATR(length) or 0 when off
Calculation: bearish gap = high < low[2] AND close[1] < low[2] AND (open[1] - close[1]) / open[1] > impulse threshold AND low[2] - high >= minimum gap, with top = low[2] and bottom = high, where minimum gap = gap multiple * ATR(length) or 0 when off
Calculation: gap entry level = top - entry depth * (top - bottom) for a bullish gap, bottom + entry depth * (top - bottom) for a bearish gap
Calculation: long displacement = close > high of an eligible sellside sweep bar s, where this is the first bar after s with close above high of s, the previous bar time <= time of s + displacement window, and no bar strictly between s and this bar has low < raid extreme of s
Calculation: short displacement = close < low of an eligible buyside sweep bar s, where this is the first bar after s with close below low of s, the previous bar time <= time of s + displacement window, and no bar strictly between s and this bar has high > raid extreme of s
Calculation: same-side raid ordinal = number of sweeps on the same side as this sweep since the current session started, including this sweep
Calculation: bias = +1 if bias close > bias reference, -1 if bias close < bias reference, else 0; per bias source, HTF EMA compares close of the last completed T1 bar with EMA(close, bias length, T1, last completed bar), HTF candle compares close with open of the last completed T1 bar, and midnight open compares chart close with midnight open
Calculation: zone position = (close - zone low) / (zone high - zone low), where zone high and zone low are the high and low of the range selected by the zone range setting: last completed T1 bar, chart bars since the day started, or chart bars since the active session started
Calculation: SMT divergence (long) = low <= lowest low of the last SMT lookback chart bars including this bar AND peer low > lowest peer low over those bars; SMT divergence (short) = high >= highest high of those bars AND peer high < highest peer high over those bars; peer high and peer low are those of the correlated instrument
Calculation: session progress = (bar time - active session start) / active session length
Long: sellside sweep
Short: buyside sweep
Long: eligible sellside sweep
Short: eligible buyside sweep
Long: eligible sellside sweep AND stop width ok
Short: eligible buyside sweep AND stop width ok
Long: long displacement AND stop width ok
Short: short displacement AND stop width ok
Long: long displacement AND an unfilled bullish gap formed at or after the sweep bar of this displacement exists
Short: short displacement AND an unfilled bearish gap formed at or after the sweep bar of this displacement exists
Long: long displacement AND no unfilled bullish gap formed at or after the sweep bar of this displacement exists AND fallback enabled AND stop width ok
Short: short displacement AND no unfilled bearish gap formed at or after the sweep bar of this displacement exists AND fallback enabled AND stop width ok
Long: low <= gap entry level taken at the long displacement bar for the most recent unfilled bullish gap formed at or after that displacement's sweep bar AND previous bar time <= displacement bar time + fill window AND no bar strictly between the displacement bar and this bar has low < raid extreme AND stop width ok
Short: high >= gap entry level taken at the short displacement bar for the most recent unfilled bearish gap formed at or after that displacement's sweep bar AND previous bar time <= displacement bar time + fill window AND no bar strictly between the displacement bar and this bar has high > raid extreme AND stop width ok
Exit: long, bar after entry AND low <= active stop
Exit: long, bar after entry AND high >= target AND low > active stop AND (partial disabled OR partial exit taken before this bar)
Exit: long, bar after entry AND high >= first target AND low > active stop AND partial enabled AND no partial exit taken before this bar
Exit: long, bar after entry AND bar time > entry time + horizon AND low > active stop AND high < target
Exit: short, bar after entry AND high >= active stop
Exit: short, bar after entry AND low <= target AND high < active stop AND (partial disabled OR partial exit taken before this bar)
Exit: short, bar after entry AND low <= first target AND high < active stop AND partial enabled AND no partial exit taken before this bar
Exit: short, bar after entry AND bar time > entry time + horizon AND high < active stop AND low > target