Calculation: Daily VWAP = cumulative sum of OHLC4 × volume divided by cumulative volume, resetting at each UTC calendar-day boundary.
Calculation: Session VWAP = cumulative sum of OHLC4 × volume divided by cumulative volume, resetting when any configured session opens, accumulating while any configured session is active, and clearing outside all sessions.
Calculation: Value-area boundaries = for each profile, reset equal-width price buckets at the anchor. Set the fixed price range to the anchor bar midpoint plus and minus a multiple of the greater of its high-low range and a minimum price increment. For each included bar with positive volume, add to each overlapping bucket the bar volume multiplied by the overlap of the bucket and bar high-low range divided by the greater of the bar range and the minimum price increment. Choose the lowest bucket with the greatest volume as the point of control. Starting there, expand toward the adjacent bucket with greater volume, choosing the upper bucket on a tie, until the selected volume reaches the configured fraction of total bucket volume or the range is exhausted. The lower edge of the lowest selected bucket and upper edge of the highest selected bucket are the value-area boundaries. The daily profile resets at its configured UTC time and includes every bar. The session profile resets when any configured session opens and includes bars while any configured session is active.
Long: close >= daily VWAP
Short: close < daily VWAP
Long: any configured session is active AND close >= session VWAP
Short: any configured session is active AND close < session VWAP
Long: close > daily profile upper value-area boundary
Short: close < daily profile lower value-area boundary
Long: any configured session is active AND close > session profile upper value-area boundary
Short: any configured session is active AND close < session profile lower value-area boundary