Calculation: Profile = Divide the range from the lowest low to the highest high over a lookback ending at the current bar into equal price rows. For each bar, divide its volume equally among all rows touched by its low-to-high range; use volume 1 when volume is missing or nonpositive. Sum the shares in each row. If the range is zero, the profile has no levels.
Calculation: Wall candidates = Enabled positive manual wall parameters; if enabled, the midpoint of the first highest-volume profile row; if enabled, volume-wall midpoints; and if enabled, pivot-cluster levels. A volume wall is a row whose volume exceeds average row volume times a threshold, exceeds the preceding row's volume, and is at least the following row's volume; use zero for a missing neighboring row. Keep the strongest walls up to a limit. To find pivot clusters, retain a limited number of the most recently confirmed pivot highs and lows, using equal left and right pivot lengths. For each retained pivot, count pivots within an ATR-multiple tolerance. Visit pivots in descending count order; if the count meets a minimum and the pivot is farther than twice the tolerance from every already selected cluster level, select the mean of pivots within the tolerance. Stop at the cluster limit. Profile-derived candidates and pivot clusters require a nonzero profile range; clusters also require positive tolerance.
Calculation: Upper wall = The lowest wall candidate strictly above the current close, if one exists.
Calculation: Lower wall = The highest wall candidate at or below the current close, if one exists.
Calculation: Flow = The moving average of volume-weighted close location divided by the moving average of the same volume. Use volume 1 when volume is missing or nonpositive; volume-weighted close location is volume times (2 × close − high − low) / (high − low), or zero when high equals low.
Calculation: Near upper wall = An upper wall exists AND ATR > 0 AND (upper wall − close) / ATR <= the near-wall threshold.
Calculation: Near lower wall = A lower wall exists AND ATR > 0 AND (close − lower wall) / ATR <= the near-wall threshold.
Long: Flow > the positive flow threshold.
Short: Flow < the negative flow threshold.
Long: Near upper wall AND flow > the positive flow threshold.
Short: Near upper wall AND flow <= the positive flow threshold.
Short: Near upper wall is false AND near lower wall AND flow < the negative flow threshold.
Long: Near upper wall is false AND near lower wall AND flow >= the negative flow threshold.
Long: The previous bar's upper wall exists AND close > the previous bar's upper wall AND previous close <= the previous bar's upper wall.
Short: The previous bar's lower wall exists AND close < the previous bar's lower wall AND previous close >= the previous bar's lower wall.
Short: The previous bar's upper wall exists AND high >= the previous bar's upper wall AND close < the previous bar's upper wall.
Long: The previous bar's lower wall exists AND low <= the previous bar's lower wall AND close > the previous bar's lower wall.