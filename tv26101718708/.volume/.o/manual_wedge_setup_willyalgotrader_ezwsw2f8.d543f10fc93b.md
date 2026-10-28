Calculation: Upper boundary = linear fit through the two assigned upper-contact highs.
Calculation: Lower boundary = linear fit through the two assigned lower-contact lows.
Calculation: Apex = intersection of the upper and lower boundaries.
Calculation: Target height = absolute price difference between the earliest assigned upper contact and earliest assigned lower contact.
Calculation: Initial stop = below the lowest assigned low for a falling wedge, or above the highest assigned high for a rising wedge, by the configured offset.
Calculation: TP3 = broken boundary plus breakout direction × 90% of target height.
Calculation: TP1 and TP2 = entry price plus their configured fractions of the entry-to-TP3 distance; TP1 fraction is less than TP2 fraction, which is less than 100%.
Long: Four distinct selected anchor candles are closed AND a valid converging wedge fit exists AND close > upper boundary after anchor 4 and before the apex AND the initial stop is below entry AND entry < TP1 < TP2 < TP3.
Short: Four distinct selected anchor candles are closed AND a valid converging wedge fit exists AND close < lower boundary after anchor 4 and before the apex AND the initial stop is above entry AND entry > TP1 > TP2 > TP3.
Exit: Long, high >= TP1 OR high >= TP2 OR high >= TP3 OR (low <= initial stop AND high < TP1 AND high < TP2) OR (TP1 was reached on an earlier bar AND low <= entry).
Exit: Short, low <= TP1 OR low <= TP2 OR low <= TP3 OR (high >= initial stop AND low > TP1 AND low > TP2) OR (TP1 was reached on an earlier bar AND high >= entry).