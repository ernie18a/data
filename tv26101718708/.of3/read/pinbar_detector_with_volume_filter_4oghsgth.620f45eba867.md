Calculation: body = abs(close - open)
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: range = high - low
Long: open != close AND range > minimum range parameter AND lower wick > upper wick AND lower wick >= body * smaller wick-to-body threshold
Long: open != close AND range > minimum range parameter AND lower wick > upper wick AND lower wick >= body * larger wick-to-body threshold
Short: open != close AND range > minimum range parameter AND upper wick > lower wick AND upper wick >= body * smaller wick-to-body threshold
Short: open != close AND range > minimum range parameter AND upper wick > lower wick AND upper wick >= body * larger wick-to-body threshold