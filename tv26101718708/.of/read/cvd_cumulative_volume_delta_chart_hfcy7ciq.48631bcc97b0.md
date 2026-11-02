Calculation: Volume delta = Sum signed volume over completed lower-timeframe bars within the chart bar. Assign each lower-timeframe bar positive volume if its close > open and negative volume if its close < open; if close = open, use the sign of its close minus the previous lower-timeframe close, or the last known polarity if those closes are equal. If no polarity is known, assign positive volume.
Calculation: Oscillator = Either volume delta or volume delta divided by total lower-timeframe volume for the chart bar; optionally accumulate the selected value from the current reset bar. A reset can occur at the start of a higher-timeframe bar, at a configured time contained in an intraday chart bar, or on a Supertrend direction change, Aroon lines crossing, or Parabolic SAR crossing close. The accumulation can also run without resets.
Long: Oscillator > 0
Short: Oscillator < 0
Long: Volume delta > 0 AND close <= open
Short: Volume delta < 0 AND close >= open
Long: Supertrend changes to an uptrend OR Aroon up crosses above Aroon down OR Parabolic SAR crosses below close
Short: Supertrend changes to a downtrend OR Aroon up crosses below Aroon down OR Parabolic SAR crosses above close