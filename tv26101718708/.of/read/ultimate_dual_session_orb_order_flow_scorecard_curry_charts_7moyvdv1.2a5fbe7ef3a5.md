Calculation: Opening range high and low = highest high and lowest low of chart bars in the most recent enabled opening-range session; reset at the start of each session and update through the session.
Calculation: Value area high and low = opening range high minus a fraction of the range size and opening range low plus the same fraction of the range size, respectively; update at the end of each opening-range session and retain until the next session ends.
Calculation: Bullish breakout = close > opening range high OR close > value area high.
Calculation: Bearish breakout = close < opening range low OR close < value area low.
Calculation: Confirmation counts = consecutive chart bars outside an opening-range session satisfying the respective breakout condition; reset both counts during a session or when neither condition holds. If both breakout conditions hold, increment the bullish count and reset the bearish count; otherwise increment the matching count and reset the other.
Long: Outside an opening-range session AND bullish confirmation count >= required confirmation count.
Short: Outside an opening-range session AND bearish confirmation count >= required confirmation count.