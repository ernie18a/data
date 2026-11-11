Calculation: Body = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Long: open != close AND high - low > minimum range threshold AND lower wick > upper wick AND ((lower-ratio tier enabled = true AND lower wick >= body * lower ratio) OR (higher-ratio tier enabled = true AND lower wick >= body * higher ratio))
Short: open != close AND high - low > minimum range threshold AND upper wick > lower wick AND ((lower-ratio tier enabled = true AND upper wick >= body * lower ratio) OR (higher-ratio tier enabled = true AND upper wick >= body * higher ratio))