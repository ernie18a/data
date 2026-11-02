Calculation: Volume score = either volume divided by its simple moving average, or volume minus that average divided by its standard deviation; both averages include the current bar.
Calculation: Candle direction = positive when (2 × close − high − low) / (high − low) is positive; negative when it is negative. If that ratio is zero, use the sign of close − open, with a zero body considered positive. If high = low, the direction is positive when close >= open and negative otherwise.
Calculation: Cumulative volume delta = running sum of volume × (2 × (close − low) / (high − low) − 1); add zero when high = low.
Long: Volume score >= moderate threshold AND candle direction > 0.
Short: Volume score >= moderate threshold AND candle direction < 0.
Long: Volume score >= extreme threshold AND candle direction < 0 AND low >= lowest low over the preceding lookback bars.
Short: Volume score >= extreme threshold AND candle direction > 0 AND high <= highest high over the preceding lookback bars.
Long: Cumulative volume delta > cumulative volume delta a lookback number of bars ago.
Short: Cumulative volume delta < cumulative volume delta a lookback number of bars ago.