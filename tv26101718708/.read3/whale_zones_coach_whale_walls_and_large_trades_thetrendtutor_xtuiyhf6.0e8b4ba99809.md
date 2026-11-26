Calculation: Whale walls = over the latest lookback bars, divide the range from lowest low to highest high into the configured number of equal price rows; for each positive-volume bar, distribute its volume equally among rows from its low-price row through its high-price row, clipping row indices to the range; classify each row by its midpoint, above close as sell and otherwise buy, and apply the optional maximum-distance filter; process sell then buy rows, selecting up to the configured walls per side by repeatedly choosing the highest-volume eligible unused row whose volume is at least the eligible-side average times the wall-strength multiplier, then mark that row and all rows within the minimum gap as used; sell-side and buy-side volumes are the sums of selected row volumes on each side
Long: Z-score(volume, volume baseline lookback) >= large-trade threshold AND close >= open
Short: Z-score(volume, volume baseline lookback) >= large-trade threshold AND close < open
Long: a buy whale wall is selected
Short: a sell whale wall is selected
Long: close > a selected whale wall AND close[1] <= that wall's current price
Short: close < a selected whale wall AND close[1] >= that wall's current price
Long: buy-side selected-wall volume > sell-side selected-wall volume * pressure ratio
Short: sell-side selected-wall volume > buy-side selected-wall volume * pressure ratio