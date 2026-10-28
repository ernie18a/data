Calculation: Neo Core = supersmoother of HLC3 using a long lookback.
Calculation: Neo Wall direction = trailing ATR wall regime: smooth close with a supersmoother; use a longer ATR lookback than the smoothing lookback; trail the lower smoothed-close-minus-ATR boundary while direction is up and the upper smoothed-close-plus-ATR boundary while direction is down; reverse after two consecutive closes beyond the active wall.
Calculation: Trend Guide direction = direction of a held HLC3 guide: move the guide up or down by ATR times a multiplier only when HLC3 crosses the prior guide plus or minus its held ATR range; otherwise hold it. Use the last completed chart bar to determine direction, retaining the last nonzero direction when the guide is unchanged.
Calculation: Flow = smoothed MFI of HL2, centered at 50. Track recent positive and negative Flow values separately; positive and negative averages use values from their respective sides of zero. Strong positive threshold is the greater of the positive average and a positive offset; strong negative threshold is the lesser of the negative average and a negative offset.
Calculation: Flow direction bias = Flow change from a short lookback exceeds a threshold based on the high-to-low range of Flow over a longer lookback, or Flow is above zero and rising for long bias; the inverse conditions give short bias.
Calculation: Core slope bias = Neo Core change over a short lookback exceeds a fraction of the range of that change over a longer lookback for long bias; the inverse condition gives short bias.
Calculation: Candle momentum bias = MACD histogram from a MACD with a faster and a slower average, and a signal average; long bias when the histogram is positive and its absolute value is growing beyond a range-based threshold, or negative and shrinking beyond that threshold; short bias when negative and growing, or positive and shrinking. Compare absolute histogram change over a short lookback with a fraction of its high-to-low range over a longer lookback.
Calculation: Context score = moving average of the weighted Flow direction bias, Core slope bias, and Candle momentum bias over a short lookback, read from the prior completed bar.
Calculation: Stretch touch = bar high reaches or exceeds the upper stretch boundary, or bar low reaches or falls below the lower stretch boundary. Boundaries are centered on Neo Core and offset by a smoothed true-range measure; the outer boundary is farther from Core than the inner boundary.
Calculation: Wall setup touch = prior direction is up and current low touches or falls below the prior wall plus its ATR buffer, or prior direction is down and current high touches or rises above the prior wall minus its ATR buffer.
Calculation: Setup touch = Wall setup touch OR Stretch touch.
Long: Neo Wall direction is up.
Long: MACD value > 0 AND MACD histogram > 0.
Long: Neo Wall direction is up AND Trend Guide direction is up.
Long: Flow is positive AND Flow is at least its positive average AND Flow is not in the strong positive zone.
Long: Flow is in the strong positive zone.
Long: Setup touch AND not bearish strong Flow occurred within the prior completed context lookback AND upper Stretch was not touched AND (lower Stretch was touched OR long Context score > short Context score).
Short: Neo Wall direction is down.
Short: MACD value < 0 AND MACD histogram < 0.
Short: Neo Wall direction is down AND Trend Guide direction is down.
Short: Flow is negative AND Flow is at most its negative average AND Flow is not in the strong negative zone.
Short: Flow is in the strong negative zone.
Short: Setup touch AND not bullish strong Flow occurred within the prior completed context lookback AND lower Stretch was not touched AND (upper Stretch was touched OR short Context score > long Context score).