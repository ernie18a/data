Calculation: Volume delta = Sum signed volume of the completed lower-timeframe bars within the chart bar. Assign positive volume when a lower-timeframe close is above its open, negative when below; if equal, use the sign of the close change from the preceding lower-timeframe bar, or the preceding bar's sign if that change is zero.
Calculation: Volume profile = Divide the range from the lowest low to the highest high over the lookback into equal price levels. For each chart bar in the lookback, divide its estimated buy volume, max((volume + volume delta) / 2, 0), and estimated sell volume, max((volume - volume delta) / 2, 0), equally among all levels touched by its low-to-high range. Classify both shares as large when their combined bar volume exceeds a multiple of that bar's volume SMA; otherwise classify them as small. Sum each category at each level. The point of control is the midpoint of the level with the greatest total volume, choosing the lowest level on a tie. Starting at that level, expand the value area one adjacent level at a time toward the larger adjacent volume, choosing the upper level on a tie, until its accumulated volume reaches the specified fraction of total profile volume or all levels are included. Value-area high and low are the outer boundaries of the included levels.
Long: Close > point of control AND ATR > 0
Short: Close <= point of control AND ATR > 0
Long: Close > value-area high
Short: Close < value-area low
Long: Volume delta >= 0
Short: Volume delta < 0
Long: Any profile level's total volume > 0 AND its large-volume share > threshold AND its large buy volume > its large sell volume
Short: Any profile level's total volume > 0 AND its large-volume share > threshold AND its large buy volume <= its large sell volume