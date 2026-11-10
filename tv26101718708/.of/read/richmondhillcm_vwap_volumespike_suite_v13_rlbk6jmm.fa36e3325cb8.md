Calculation: Anchored VWAP = cumulative sum of price source × volume divided by cumulative volume, resetting at the start of each configurable calendar period; price source is selected from the available bar prices.
Calculation: Direction reference = configurable choice of anchored VWAP, current open, or previous close.
Long: Volume > 0 AND volume > simple moving average of volume × spike threshold AND close > direction reference.
Short: Volume > 0 AND volume > simple moving average of volume × spike threshold AND close < direction reference.
Long: Close > anchored VWAP AND previous close <= previous anchored VWAP.
Short: Close < anchored VWAP AND previous close >= previous anchored VWAP.