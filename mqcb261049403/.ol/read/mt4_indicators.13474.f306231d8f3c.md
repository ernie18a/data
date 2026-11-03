Calculation: Up-bounce strength = for each of the last Slowing bars where close is at least previous close minus 20% of that bar’s high-low range, add (close − low) × (2 − low / Tango moving average); divide the sum by Slowing and Point
Calculation: Down-bounce strength = for each of the last Slowing bars where close is at most previous close plus 20% of that bar’s high-low range, add (high − close) × (2 − high / Tango moving average); divide the sum by Slowing and Point
Calculation: Signal = 2 × (up-bounce strength − down-bounce strength) × abs((up-bounce strength − down-bounce strength) / (up-bounce strength + down-bounce strength))
Calculation: Trend strength = average Signal over the shorter lookback; Slow trend strength = average Signal over the longer lookback
Long: Up-bounce strength > 0 OR Trend strength > 0
Short: Down-bounce strength < 0 OR Trend strength < 0