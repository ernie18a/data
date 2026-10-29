Calculation: Footprint row buy/sell volume = allocate each lower-timeframe bar’s volume to price rows in proportion to the overlap of its price range with each row; assign volume to buys when its close is above its open, to sells when below, and split equally when equal. Use lower-timeframe bars within the chart bar, including a still-forming lower-timeframe bar when the chart bar is forming.
Calculation: Bar delta = sum across the chart bar’s price rows of (row buy volume − row sell volume).
Long: The close is below the open AND buy volume in the configured number of lowest price rows divided by their total volume is at least the configured absorption threshold
Short: The close is above the open AND sell volume in the configured number of highest price rows divided by their total volume is at least the configured absorption threshold
Long: The low is below the lows of the preceding configured lookback bars AND bar delta is positive
Short: The high is above the highs of the preceding configured lookback bars AND bar delta is negative
Long: Bar delta is positive AND bar delta on the preceding closed chart bar is nonpositive
Short: Bar delta is negative AND bar delta on the preceding closed chart bar is nonnegative