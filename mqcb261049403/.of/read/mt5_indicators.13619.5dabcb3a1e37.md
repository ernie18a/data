Calculation: Direction = initialize bearish; on each bar, set bullish if its high is greater than the high a lookback period earlier, then set bearish if its low is lower than the low the same lookback period earlier; otherwise retain the previous direction. The bearish assignment takes precedence when both comparisons are true.
Long: Chart-timeframe direction is bullish.
Short: Chart-timeframe direction is bearish.
Long: Direction calculated on the still-forming higher-timeframe bar, sampled at the first chart bar of that higher-timeframe bar and held until the next higher-timeframe bar, is bullish.
Short: Direction calculated on the still-forming higher-timeframe bar, sampled at the first chart bar of that higher-timeframe bar and held until the next higher-timeframe bar, is bearish.