Calculation: Applied price = a selectable bar price: open, high, low, close, (high + low)/2, (high + low + close)/3, (high + low + 2 × close)/4, (open + close)/2, or (open + high + low + close)/4; alternatively, use high when close > open, low when close < open, and close otherwise; or (high + close)/2 when close > open, (low + close)/2 when close < open, and close otherwise; or Demark price, calculated by setting X to (high + low + close + low)/2 when close < open, (high + low + close + high)/2 when close > open, and (high + low + 2 × close)/2 otherwise, then returning X - (high + low)/2.
Calculation: Rounded double LWMA = a linear weighted moving average of the applied price, smoothed again with a linear weighted moving average of the same length, plus a configurable price offset, rounded to a configurable price increment. Each average gives the newest observation the greatest weight.
Calculation: Line direction = up when rounded double LWMA > its previous value, down when it < its previous value, and otherwise the previous line direction.
Calculation: Higher-timeframe line direction = line direction calculated from higher-timeframe bars using the bar still forming and carried across chart bars within that higher-timeframe bar.
Long: Line direction = up.
Short: Line direction = down.
Long: Applied price > rounded double LWMA normalized to the instrument's price precision.
Short: Applied price < rounded double LWMA normalized to the instrument's price precision.
Long: Higher-timeframe line direction = up.
Short: Higher-timeframe line direction = down.
Long: Higher-timeframe line direction = up AND previous chart bar's higher-timeframe line direction != up.
Short: Higher-timeframe line direction = down AND previous chart bar's higher-timeframe line direction != down.