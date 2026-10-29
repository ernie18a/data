Calculation: Ask and bid volume at each price level = Divide the chart bar’s high-low range into the configured number of equal price levels. For each lower-timeframe bar within the chart bar, including the bar still forming, distribute its volume equally across the price levels intersected by its high-low range; assign it to ask volume if close > open, otherwise to bid volume.
Calculation: Total delta = Sum of ask volume across all price levels minus sum of bid volume across all price levels.
Long: Total delta > 0
Long: At least one price level has ask volume > bid volume × imbalance ratio
Long: At least three consecutive price levels each have ask volume > bid volume × imbalance ratio
Long: Bottom-level bid volume > bottom-level ask volume × imbalance ratio AND bottom-level ask volume < 10 × minimum tick size
Long: Close < open AND total delta > 0
Short: Total delta <= 0
Short: At least one price level has bid volume > ask volume × imbalance ratio
Short: At least three consecutive price levels each have bid volume > ask volume × imbalance ratio
Short: Top-level ask volume > top-level bid volume × imbalance ratio AND top-level bid volume < 10 × minimum tick size
Short: Close > open AND total delta < 0