Calculation: Confirmed up fractal = On the configured source timeframe, a candidate bar’s high is strictly higher than the highs of the n bars before it; for at least one k from 0 to 4, the next k highs are no higher than the candidate and the following n highs are strictly lower. The pivot is confirmed after those following bars complete.
Calculation: Confirmed down fractal = On the configured source timeframe, a candidate bar’s low is strictly lower than the lows of the n bars before it; for at least one k from 0 to 4, the next k lows are no lower than the candidate and the following n lows are strictly higher. The pivot is confirmed after those following bars complete.
Calculation: Resistance line = The maximum of the open and close of a confirmed up-fractal pivot; it is broken once a bar closes above it.
Calculation: Support line = The minimum of the open and close of a confirmed down-fractal pivot; it is broken once a bar closes below it.
Long: Confirmed down fractal = true
Long: Line-test alert enabled AND line mode enabled AND an unbroken support line exists AND low <= support line AND high >= support line
Short: Confirmed up fractal = true
Short: Line-test alert enabled AND line mode enabled AND an unbroken resistance line exists AND low <= resistance line AND high >= resistance line