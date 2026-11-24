Calculation: Footprint rows = on each chart bar, split its low-to-high range into max(1, round(range / row size)) equal rows; row size is either round-to-tick(ATR(chart bars, lookback) × scale) or a separate fixed-size parameter; for each row, sum T1 intrabar volume weighted by the fraction of its high-low range overlapping the row, classifying volume as buy when close > open, sell when close < open, and half of each when close = open; if an intrabar range is zero, use its full volume for each overlapping row. Use T1 intrabars within the current chart bar, including a still-forming T1 bar.
Calculation: Row delta ratio = (row buy volume − row sell volume) / (row buy volume + row sell volume), or zero when total row volume is zero.
Calculation: CVD bar delta = current chart bar CVD from T1 intrabars − prior chart bar CVD from T1 intrabars; evaluate on chart bars using the current bar, including T1 data still forming within it.
Long: footprint row delta ratio > 0
Short: footprint row delta ratio < 0
Long: a consecutive run of footprint rows has row delta ratio ≥ the stacked-imbalance threshold and contains at least the minimum-row-count parameter
Short: a consecutive run of footprint rows has row delta ratio ≤ −the stacked-imbalance threshold and contains at least the minimum-row-count parameter
Long: close < open AND the number of footprint rows is at least the absorption row-count parameter AND buy volume summed across the bottom absorption rows / their total volume ≥ the absorption threshold
Short: close > open AND the number of footprint rows is at least the absorption row-count parameter AND sell volume summed across the top absorption rows / their total volume ≥ the absorption threshold
Long: low < lowest(low[1], divergence lookback) AND CVD bar delta > 0
Short: high > highest(high[1], divergence lookback) AND CVD bar delta < 0
Long: CVD bar delta > 0 AND prior chart bar CVD bar delta ≤ 0
Short: CVD bar delta < 0 AND prior chart bar CVD bar delta ≥ 0
Long: CVD bar delta ≥ 0
Short: CVD bar delta < 0
Long: the top footprint row has total volume > 0 AND its buy volume / total volume ≥ the unfinished-business threshold
Short: the bottom footprint row has total volume > 0 AND its sell volume / total volume ≥ the unfinished-business threshold