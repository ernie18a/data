Calculation: HTF liquidity levels = the high and low of each last completed higher-timeframe bar; retain the most recent levels.
Calculation: HTF structure bias = direction of the latest break of a confirmed higher-timeframe pivot high or low, using the higher-timeframe bar still forming; bias persists until another break.
Calculation: Swing pivots = confirmed centered pivot highs and lows; retain the latest unbroken pivot high and low.
Calculation: CHoCH range = highest high and lowest low from the pivot bar whose level broke through the break bar, inclusive.
Calculation: Fibonacci price(r) = range start + (range end − range start) × r; for upward CHoCH, start at the range low and end at the range high; for downward CHoCH, start at the range high and end at the range low.
Calculation: Bullish pinbar = lower wick > body × 1.5 and lower wick > ATR(14) × 0.2; bearish pinbar = upper wick > body × 1.5 and upper wick > ATR(14) × 0.2.
Long: close (or high when wick breaks are enabled) > latest unbroken swing pivot high.
Long: HTF low level was swept (low < level) and close > level and bullish pinbar.
Long: previously swept HTF low level is retested (low <= level) and close > level.
Long: upward CHoCH (break of latest unbroken swing pivot high while prior structure direction is bearish) and price overlaps the Fibonacci 0.318–0.618 zone, and at CHoCH HTF structure bias is bullish and close >= VWAP.
Short: close (or low when wick breaks are enabled) < latest unbroken swing pivot low.
Short: HTF high level was swept (high > level) and close < level and bearish pinbar.
Short: previously swept HTF high level is retested (high >= level) and close < level.
Short: downward CHoCH (break of latest unbroken swing pivot low while prior structure direction is bullish) and price overlaps the Fibonacci 0.318–0.618 zone, and at CHoCH HTF structure bias is bearish and close <= VWAP.
Exit: long, low <= Fibonacci price(-0.23) OR high >= Fibonacci price(1.47) OR high >= Fibonacci price(2.56) OR (Fibonacci price(2.56) was reached and high >= Fibonacci price(3.61)) OR (Fibonacci price(4.23) was reached and high >= Fibonacci price(5.61)).
Exit: short, high >= Fibonacci price(-0.23) OR low <= Fibonacci price(1.47) OR low <= Fibonacci price(2.56) OR (Fibonacci price(2.56) was reached and low <= Fibonacci price(3.61)) OR (Fibonacci price(4.23) was reached and low <= Fibonacci price(5.61)).