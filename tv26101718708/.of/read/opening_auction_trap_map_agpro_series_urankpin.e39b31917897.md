Calculation: Auction high and low = highest high and lowest low of chart bars in the latest opening auction window; the range becomes valid after that window ends if its high is greater than its low, and remains valid until the next opening auction begins.
Calculation: Trap window = active session bars after a valid auction, with the first bar after the auction counted as bar 1 and the count no greater than the trap lookback.
Calculation: Upper wick fraction = (high - max(open, close)) / (high - low); use 0 when high equals low.
Calculation: Lower wick fraction = (min(open, close) - low) / (high - low); use 0 when high equals low.
Long: Chart timeframe is intraday and no greater than the maximum supported chart timeframe AND auction range is valid AND close > auction high.
Long: Chart timeframe is intraday and no greater than the maximum supported chart timeframe AND trap window is open AND low < auction low AND close > auction low AND lower wick fraction >= wick quality threshold.
Short: Chart timeframe is intraday and no greater than the maximum supported chart timeframe AND auction range is valid AND close < auction low.
Short: Chart timeframe is intraday and no greater than the maximum supported chart timeframe AND trap window is open AND high > auction high AND close < auction high AND upper wick fraction >= wick quality threshold.