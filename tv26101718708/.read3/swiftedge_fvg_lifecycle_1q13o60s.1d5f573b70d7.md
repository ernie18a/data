Calculation: Bullish gap (top = low, bottom = high[2]) = low > high[2] AND low - high[2] >= min gap size * ATR(atr lookback) AND (displacement filter disabled OR close[1] - open[1] >= displacement multiple * ATR(atr lookback)[1])
Calculation: Bearish gap (top = low[2], bottom = high) = high < low[2] AND low[2] - high >= min gap size * ATR(atr lookback) AND (displacement filter disabled OR open[1] - close[1] >= displacement multiple * ATR(atr lookback)[1])
Calculation: Bullish merge = merging enabled AND newest live chart gap is a bullish gap that is untouched, not inverted and confirmed within merge window bars AND Bullish gap bottom <= its top + merge tolerance * ATR(atr lookback) AND Bullish gap top >= its bottom - merge tolerance * ATR(atr lookback)
Calculation: Bearish merge = merging enabled AND newest live chart gap is a bearish gap that is untouched, not inverted and confirmed within merge window bars AND Bearish gap bottom <= its top + merge tolerance * ATR(atr lookback) AND Bearish gap top >= its bottom - merge tolerance * ATR(atr lookback)
Calculation: Bullish gap zone (chart) = the gap object created or extended on a bar where Bullish gap holds: Bullish gap itself, or if Bullish merge holds, the newest live chart gap extended to cover Bullish gap (top = max of both tops, bottom = min of both bottoms), confirmed on that bar
Calculation: Bearish gap zone (chart) = the gap object created or extended on a bar where Bearish gap holds: Bearish gap itself, or if Bearish merge holds, the newest live chart gap extended to cover Bearish gap (top = max of both tops, bottom = min of both bottoms), confirmed on that bar
Calculation: Bullish gap on Tn = the gap created when a new Tn bar starts, if low of last completed Tn bar > high of the Tn bar 2 bars before it AND (last completed low - earlier high) >= min gap size * ATR(atr lookback) on the last completed Tn bar; top = last completed low, bottom = earlier high
Calculation: Bearish gap on Tn = the gap created when a new Tn bar starts, if high of last completed Tn bar < low of the Tn bar 2 bars before it AND (earlier low - last completed high) >= min gap size * ATR(atr lookback) on the last completed Tn bar; top = earlier low, bottom = last completed high
Calculation: Bullish inversion on X = a bar's close below the bottom of a live bullish gap on X (X = chart: Bullish gap zone (chart); X = Tn: Bullish gap on Tn), where live means not inverted, bars since its last confirmation between 1 and max gap age, and inversion enabled, AND either fill by close-through only or no earlier bar since its confirmation had low <= its bottom
Calculation: Bearish inversion on X = a bar's close above the top of a live bearish gap on X (X = chart: Bearish gap zone (chart); X = Tn: Bearish gap on Tn), where live means not inverted, bars since its last confirmation between 1 and max gap age, and inversion enabled, AND either fill by close-through only or no earlier bar since its confirmation had high >= its top
Calculation: Long stop price = bottom of the gap or iFVG that produced the long entry - stop buffer * ATR(atr lookback) on the entry bar
Calculation: Short stop price = top of the gap or iFVG that produced the short entry + stop buffer * ATR(atr lookback) on the entry bar
Long: Bullish gap AND NOT Bullish merge
Long: Bullish gap zone (chart), bars since its last confirmation between 1 and max gap age, not inverted, not previously touched, low <= zone top
Long: Bullish gap zone (chart), bars since its last confirmation between 1 and max gap age, not inverted, not previously traded, low <= entry level, where entry level is zone top for gap-edge entry or zone midpoint for midpoint entry
Long: Bullish gap on T1, bars since its last confirmation between 1 and max gap age, not inverted, not previously touched, low <= gap top
Long: Bullish gap on T2, bars since its last confirmation between 1 and max gap age, not inverted, not previously touched, low <= gap top
Long: Bearish inversion on chart bars
Long: Bearish inversion on T1
Long: Bearish inversion on T2
Long: first bar after a Bearish inversion on chart bars with low <= that gap's top, where that bar is within max gap age bars of the gap's last confirmation and its close >= that gap's bottom
Long: first bar after a Bearish inversion on T1 with low <= that gap's top, where that bar is within max gap age bars of the gap's last confirmation and its close >= that gap's bottom
Long: first bar after a Bearish inversion on T2 with low <= that gap's top, where that bar is within max gap age bars of the gap's last confirmation and its close >= that gap's bottom
Short: Bearish gap AND NOT Bearish merge
Short: Bearish gap zone (chart), bars since its last confirmation between 1 and max gap age, not inverted, not previously touched, high >= zone bottom
Short: Bearish gap zone (chart), bars since its last confirmation between 1 and max gap age, not inverted, not previously traded, high >= entry level, where entry level is zone bottom for gap-edge entry or zone midpoint for midpoint entry
Short: Bearish gap on T1, bars since its last confirmation between 1 and max gap age, not inverted, not previously touched, high >= gap bottom
Short: Bearish gap on T2, bars since its last confirmation between 1 and max gap age, not inverted, not previously touched, high >= gap bottom
Short: Bullish inversion on chart bars
Short: Bullish inversion on T1
Short: Bullish inversion on T2
Short: first bar after a Bullish inversion on chart bars with high >= that gap's bottom, where that bar is within max gap age bars of the gap's last confirmation and its close <= that gap's top
Short: first bar after a Bullish inversion on T1 with high >= that gap's bottom, where that bar is within max gap age bars of the gap's last confirmation and its close <= that gap's top
Short: first bar after a Bullish inversion on T2 with high >= that gap's bottom, where that bar is within max gap age bars of the gap's last confirmation and its close <= that gap's top
Exit: long, low <= long stop price
Exit: long, bars since entry >= 1 AND high >= entry price + target R * abs(entry price - long stop price)
Exit: long, bars since entry >= max holding bars
Exit: short, high >= short stop price
Exit: short, bars since entry >= 1 AND low <= entry price - target R * abs(entry price - short stop price)
Exit: short, bars since entry >= max holding bars