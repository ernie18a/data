Calculation: Anchored VWAP = cumulative sum of OHLC4 multiplied by volume, divided by cumulative volume, from the anchor bar through the current bar; undefined when cumulative volume is zero.
Calculation: Session VWAP = anchored VWAP from the latest futures-day reset; before the first reset, anchor at the first available bar.
Calculation: New York VWAP = anchored VWAP from the latest New York session open, defined only during that session.
Calculation: Previous New York VWAP = anchored VWAP from the preceding New York session open through the current bar, defined only during the current New York session.
Calculation: High-anchored VWAP = anchored VWAP from the most recent bar whose high equals or exceeds the highest high since the latest futures-day reset; initialize at the first available bar or reset bar.
Calculation: Low-anchored VWAP = anchored VWAP from the most recent bar whose low equals or falls below the lowest low since the latest futures-day reset; initialize at the first available bar or reset bar.
Calculation: Opening range high and low = highest high and lowest low from the New York session open through the end of the opening-range period, inclusive; retain these levels until the next session open.
Calculation: Bullish count = number of the five VWAPs above that are defined and below the current close.
Long: close > session VWAP OR close > New York VWAP OR close > previous New York VWAP OR close > high-anchored VWAP OR close > low-anchored VWAP
Short: close <= session VWAP OR session VWAP is undefined OR close <= New York VWAP OR New York VWAP is undefined OR close <= previous New York VWAP OR previous New York VWAP is undefined OR close <= high-anchored VWAP OR high-anchored VWAP is undefined OR close <= low-anchored VWAP OR low-anchored VWAP is undefined
Long: close > opening range high
Short: close < opening range low
Long: bullish count >= four
Short: bullish count <= one