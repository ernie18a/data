Calculation: Bar delta = sum, over all completed lower-timeframe bars within the chart bar, of volume when close > open, negative volume when close < open, and zero when close = open; if no lower-timeframe bars are available, apply the same classification to the chart bar.
Calculation: Cumulative volume delta = cumulative sum of bar delta, optionally reset to zero before adding the current bar's delta at each session, day, or week boundary.
Calculation: Confirmed pivot high or low = a high or low that is respectively the maximum or minimum over equal numbers of chart bars before and after it; evaluate it on the bar that completes the right-hand lookback, with ties resolved in favor of the most recent extreme.
Calculation: Footprint bin delta = sum of classified lower-timeframe volume deltas within a chart bar whose lower-timeframe closes fall in the same equal-width bin of that chart bar's high-low range; clamp closes to the range's end bins. If lower-timeframe bars are unavailable, assign the chart bar's delta to its close bin.
Calculation: Profile row delta = sum of chart-bar deltas over a lookback, with each bar's delta divided equally among all equal-width price rows overlapped by its high-low range. Rows span the lookback's lowest low to highest high.
Long: A newly confirmed pivot low is below the preceding confirmed pivot low AND cumulative volume delta at the new pivot is above its value at the preceding pivot.
Short: A newly confirmed pivot high is above the preceding confirmed pivot high AND cumulative volume delta at the new pivot is below its value at the preceding pivot.
Long: Volume > 0 AND bar delta / volume > positive imbalance threshold.
Short: Volume > 0 AND bar delta / volume < negative imbalance threshold.
Long: The current consecutive run of bars with volume > 0 AND bar delta / volume > positive imbalance threshold equals the stacked-imbalance count.
Short: The current consecutive run of bars with volume > 0 AND bar delta / volume < negative imbalance threshold equals the stacked-imbalance count.
Long: SMA of volume > 0 AND volume > SMA of volume × volume multiplier AND ATR > 0 AND high - low < ATR × range multiplier AND absolute difference between low and the latest confirmed pivot low <= ATR.
Short: SMA of volume > 0 AND volume > SMA of volume × volume multiplier AND ATR > 0 AND high - low < ATR × range multiplier AND absolute difference between high and the latest confirmed pivot high <= ATR.
Long: A pivot low is newly confirmed AND bar delta at that pivot > 0.
Short: A pivot high is newly confirmed AND bar delta at that pivot < 0.
Long: Bar delta >= 0.
Short: Bar delta < 0.
Long: Cumulative volume delta >= 0.
Short: Cumulative volume delta < 0.
Long: A footprint bin's delta > 0.
Short: A footprint bin's delta < 0.
Long: A profile row's delta > 0.
Short: A profile row's delta < 0.