Calculation: Volume z-score = (volume − simple moving average of volume over the baseline lookback) / standard deviation of volume over the same lookback
Calculation: Whale wall centers = Over the lookback, divide the price range from the lowest low to highest high into price rows. Spread each bar’s volume equally across rows spanned by its low and high. On each side of the current close, select up to the configured number of highest-volume rows, requiring each selected row’s volume to meet the configured multiple of that side’s average row volume; after each selection, exclude rows within the configured minimum gap. Apply the configured maximum distance from close when enabled. A row center is its price level.
Long: volume z-score ≥ the large-trade threshold AND close ≥ open
Long: a selected whale wall center ≤ close
Long: close > a selected whale wall center AND previous close ≤ that center
Short: volume z-score ≥ the large-trade threshold AND close < open
Short: a selected whale wall center > close
Short: close < a selected whale wall center AND previous close ≥ that center