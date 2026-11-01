Calculation: Structure candidates = the latest confirmed pivot high and low using the same number of bars on either side; replace each candidate when a newer same-side pivot is confirmed and mark it broken after its first break. The structure lookback is an odd full-window length; advance an even input to the next odd length.
Calculation: Structure breaks = an upward break occurs when the selected close or high is above the unbroken high candidate; a downward break occurs when the selected close or low is below the unbroken low candidate. If both occur on one bar, select upward when close >= open, otherwise downward. A shift is a break opposite to the preceding break direction; the first break and subsequent same-direction breaks are continuations. Retain the most recent shift direction until an opposite shift.
Calculation: Directional moving averages = the same selected moving-average type and length applied to low for the bullish average and high for the bearish average, or to the same selected close or (high + low) / 2 source for both. Each average exists after its corresponding equally sided price pivot is confirmed. In selective qualification mode, a pivot qualifies only if it is the first of its side or its high is higher than the preceding pivot high or its low is lower than the preceding pivot low, respectively.
Calculation: Active directional average = a qualifying same-side pivot clears its broken lock. While the average was active, a cross below the bullish average by the selected close or low, or above the bearish average by the selected close or high, locks that average until another qualifying pivot; a qualifying pivot on the same bar takes precedence over the break. The bullish average is eligible when it exists, is unlocked, close >= the average, and the average > its previous value. The bearish average is eligible when it exists, is unlocked, close <= the average, and the average < its previous value. If both are eligible, select bearish when a bearish qualifying pivot occurs or close < previous close; otherwise select bullish. If only one is eligible select it; if neither is eligible neither is active.
Calculation: Retest = after a shift, select its directional average and wait until a later bar; the first bar with low <= the average + ATR times a tolerance parameter AND high >= the average - ATR times that parameter is the retest. The average must exist but need not be active. A new shift replaces the pending direction; the first retest clears it.
Calculation: Anchored VWAP = cumulative sum of selected price source times volume divided by cumulative volume, resetting at the selected session, week, or month boundary.
Calculation: Directional health = count one point each for the latest shift having that direction and that direction's average being active; optionally count one point for close >= anchored VWAP on the long side or close < anchored VWAP on the short side, and optionally one point for RSI >= 50 on the long side or RSI < 50 on the short side. Both sides use the same enabled factors.
Calculation: Fair value gaps = a bullish gap forms when low > high two bars earlier AND the previous close > previous low + previous ATR times a threshold; its upper and lower boundaries are that low and earlier high. A bearish gap forms when high < low two bars earlier AND the previous close < previous high - previous ATR times the threshold; its boundaries are that earlier low and high. Add each gap on the next bar. A bullish gap is mitigated when the selected body low or wick low is below its lower boundary, or its wick low is below its midpoint; a bearish gap is mitigated when the selected body high or wick high is above its upper boundary, or its wick high is above its midpoint. In gap mode remove mitigated gaps; in breaker mode reverse their direction and remove them when the corresponding opposite selected body, wick, or midpoint condition invalidates them. Optionally remove older overlapping gaps and retain the selected number of recent gaps per original direction.
Long: A confirmed unbroken structure pivot high exists.
Short: A confirmed unbroken structure pivot low exists.
Long: An upward structure break occurs.
Short: A downward structure break occurs.
Long: The bullish directional average is active.
Short: The bearish directional average is active.
Long: The latest shift is bullish AND the bullish directional average is active.
Short: The latest shift is bearish AND the bearish directional average is active.
Long: The first bullish retest occurs.
Short: The first bearish retest occurs.
Long: Close >= anchored VWAP.
Short: Close < anchored VWAP.
Long: RSI >= 50.
Short: RSI < 50.
Long: Long directional health > short directional health.
Short: Short directional health > long directional health.
Long: An active bullish fair value gap or a bearish gap converted to a breaker exists.
Short: An active bearish fair value gap or a bullish gap converted to a breaker exists.
Long: An unbroken bullish fair value gap has not previously been raided AND low < its upper boundary AND close > its upper boundary.
Short: An unbroken bearish fair value gap has not previously been raided AND high > its lower boundary AND close < its lower boundary.
Exit: Long, a bearish structure shift occurs OR the active bullish directional average is broken.
Exit: Short, a bullish structure shift occurs OR the active bearish directional average is broken.