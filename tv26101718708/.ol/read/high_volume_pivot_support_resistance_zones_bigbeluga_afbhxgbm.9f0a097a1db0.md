Calculation: High-volume resistance zone = latest confirmed pivot high using equal-length left and right lookbacks, with pivot-bar volume greater than its volume moving average times a threshold; zone spans the pivot candle’s body top to that price plus ATR.
Calculation: High-volume support zone = latest confirmed pivot low using equal-length left and right lookbacks, with pivot-bar volume greater than its volume moving average times a threshold; zone spans that price minus ATR to the pivot candle’s body bottom.
Calculation: Zone CVD line = cumulative volume since the pivot, adding volume when close ≥ open and subtracting it otherwise, normalized to the zone’s price range using the cumulative delta minimum and maximum since the pivot.
Long: A high-volume resistance zone exists AND close > its top boundary (resistance breakout)
Long: A high-volume support zone exists AND close > its bottom boundary AND low[1] ≤ its top boundary AND low > its top boundary (support hold retest)
Long: A high-volume resistance zone has been broken AND close > its top boundary AND low[1] ≤ its top boundary AND low > its top boundary (flipped resistance retest)
Short: A high-volume support zone exists AND close < its bottom boundary (support breakdown)
Short: A high-volume resistance zone exists AND close < its top boundary AND high[1] ≥ its bottom boundary AND high < its bottom boundary (resistance hold retest)
Short: A high-volume support zone has been broken AND close < its bottom boundary AND high[1] ≥ its bottom boundary AND high < its bottom boundary (flipped support retest)
Short: Price reaches the high-volume resistance zone AND the Zone CVD line slopes downward
Exit: Long, close < the bottom boundary of the support zone used for the support hold retest entry