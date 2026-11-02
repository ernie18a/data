Calculation: Intrabar sample = completed lower-timeframe bars within confirmed chart bars, retaining the most recent profile-lookback × ceiling(chart timeframe / lower timeframe) samples. A sample is bullish when its close > its open; otherwise it is bearish.
Calculation: Strength threshold = volume at the floor(sample count × strength percentile) index of the retained sample volumes sorted ascending, with the index clamped to the valid range.
Calculation: Price bins = divide the range from the minimum to maximum retained sample close into equal bins; assign each sample to its close's bin, clamping the maximum close to the last bin. For each bin, sum bullish and bearish sample volumes separately; delta = bullish volume − bearish volume.
Calculation: Absorption volume per bin = sum of retained sample volumes whose bullish sample close is between its chart bar's upper body edge and high, inclusive, with a nonzero upper wick, OR whose bearish sample close is between its chart bar's low and lower body edge, inclusive, with a nonzero lower wick. An absorption peak is an interior bin whose absorption volume exceeds both adjacent bins' absorption volumes.
Calculation: Displayed volume segments = for each bin, split bullish and bearish volume into strong samples with volume >= strength threshold and weak samples with volume < strength threshold. Optionally set weak volumes to zero. Let bin length = round(profile width × bin volume / maximum bin volume); each segment length except strong bearish = round(bin length × segment volume / bin volume), and strong bearish length = bin length − the other three segment lengths. Treat lengths as zero when their denominator is zero.
Long: At least one completed lower-timeframe bar in the current chart bar has close > open AND volume >= strength threshold AND volume > 0.
Short: At least one completed lower-timeframe bar in the current chart bar has close <= open AND volume >= strength threshold AND volume > 0.
Long: Any price bin has a positive displayed strong or weak bullish volume segment length.
Short: Any price bin has a positive displayed strong or weak bearish volume segment length.
Long: Any price bin has delta > 0.
Short: Any price bin has delta < 0.
Long: Chart close is within a price bin, inclusive, AND that bin's delta > 0 AND its absolute delta equals the maximum absolute delta across bins.
Short: Chart close is within a price bin, inclusive, AND that bin's delta < 0 AND its absolute delta equals the maximum absolute delta across bins.
Long: Any absorption peak bin has chart close > its midpoint.
Short: Any absorption peak bin has chart close <= its midpoint.