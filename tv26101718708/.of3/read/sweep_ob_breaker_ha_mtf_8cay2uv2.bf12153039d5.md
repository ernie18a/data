Calculation: Chart swing high/low = latest confirmed Pivot High(Heikin-Ashi high, P1 left bars, P1 right bars) and Pivot Low(Heikin-Ashi low, P1 left bars, P1 right bars) on chart bars.
Calculation: T1 swing high/low = latest confirmed Pivot High/Low of T1 Heikin-Ashi high/low using P2 left and right bars, calculated on T1 bars and mapped to chart bars with lookahead off.
Calculation: Chart CHoC setup = a bullish sweep, when no bullish setup is pending, captures the current chart swing high and stays pending until chart Heikin-Ashi close < the latest chart swing low or > the captured high; the latter produces bullish CHoC. A bearish sweep similarly captures the current chart swing low and stays pending until chart Heikin-Ashi close > the latest chart swing high or < the captured low; the latter produces bearish CHoC. A setup clears when either condition occurs.
Calculation: T1 CHoC setup = the same sweep, capture, and invalidation sequence using T1 swing levels and T1 Heikin-Ashi low/high/close values mapped to chart bars with lookahead off; it is evaluated on chart bars, using the last completed T1 bar historically and the forming T1 bar in realtime.
Calculation: T1 direction = neutral initially; becomes bullish on bullish T1 CHoC and bearish on bearish T1 CHoC, retaining the latest direction until the opposite T1 CHoC.
Calculation: Chart OB/breaker zones = on bullish CHoC, create a bullish OB from the nearest prior bearish Heikin-Ashi candle within P3 chart bars if one exists; on bearish CHoC, create a bearish OB from the nearest prior bullish candle. A chart close below a bullish OB bottom converts it to a bearish breaker; a close above a bearish OB top converts it to a bullish breaker. A bullish breaker ends on a close below its bottom and a bearish breaker ends on a close above its top. Each new zone replaces the stored zone of its type.
Calculation: T1 OB/breaker zones = the same creation and conversion rules using T1-mapped Heikin-Ashi values; search the previous P4 chart-bar offsets in those mapped values. Zone transitions use regular chart close. T1 values use lookahead off: last completed T1 values historically and the forming T1 bar in realtime.
Long: Heikin-Ashi low < chart swing low AND Heikin-Ashi close > chart swing low.
Short: Heikin-Ashi high > chart swing high AND Heikin-Ashi close < chart swing high.
Long: bullish chart CHoC setup is pending AND Heikin-Ashi close > its captured chart swing high.
Short: bearish chart CHoC setup is pending AND Heikin-Ashi close < its captured chart swing low.
Long: T1 direction is bullish.
Short: T1 direction is bearish.
Long: an active bullish chart OB or bullish chart breaker zone exists.
Short: an active bearish chart OB or bearish chart breaker zone exists.
Long: an active bullish T1 OB or bullish T1 breaker zone exists.
Short: an active bearish T1 OB or bearish T1 breaker zone exists.
Long: T1 direction is bullish AND chart low is within an active bullish T1 OB or bullish T1 breaker zone.
Short: T1 direction is bearish AND chart high is within an active bearish T1 OB or bearish T1 breaker zone.