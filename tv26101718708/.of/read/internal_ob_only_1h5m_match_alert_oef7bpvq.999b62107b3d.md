Calculation: ParsedHigh/ParsedLow = if (high-low) >= 2*ATR(long lookback) then ParsedHigh=low and ParsedLow=high, else ParsedHigh=high and ParsedLow=low
Calculation: InternalPivots(series) = with short lookback N, leg = bearish if high[N] > highest high of the last N bars; leg = bullish if low[N] < lowest low of the last N bars; otherwise leg is unchanged. When the leg changes to bearish, pivot high = high[N]. When it changes to bullish, pivot low = low[N]. Each new pivot starts as uncrossed.
Calculation: OBSet(series) = list of active order blocks, newest first. When close crosses above the latest uncrossed pivot high, mark that pivot crossed and create a bullish OB. The bullish OB is the bar from the pivot bar to the current bar with the lowest ParsedLow, and its zone is [its ParsedLow, its ParsedHigh]. When close crosses below the latest uncrossed pivot low, mark that pivot crossed and create a bearish OB. The bearish OB is the bar from the pivot bar to the current bar with the highest ParsedHigh, with the same zone definition. Remove a bullish OB when low < its zone low. Remove a bearish OB when high > its zone high.
Calculation: OBBias(series) = using the 3 newest active OBs in OBSet (requires at least 3 OBs): BULLISH if at least 2 are bullish, else BEARISH if at least 2 are bearish, else NEUTRAL (if both counts qualify, bullish wins).
Calculation: Touched(OB) = on any earlier bar while the OB was active and not yet retested, bar overlapped the zone (high >= zone low AND low <= zone high) AND (bullish OB: close >= zone low; bearish OB: close <= zone high)
Calculation: HTF/LTF bias = OBBias computed on a higher-timeframe aggregated series (HTF, last completed bar) and on a lower-timeframe aggregated series (LTF, value as of the chart bar close), with the HTF timeframe longer than the LTF timeframe
Calculation: Matched = HTF bias != NEUTRAL AND LTF bias != NEUTRAL AND HTF bias == LTF bias
Long: on the chart series, close crosses above the latest uncrossed internal pivot high (bullish OB created)
Long: a bullish active OB has Touched true on an earlier bar, has not been retested, and close > its zone high (first time only per OB)
Long: OBBias(chart series) == BULLISH
Long: HTF bias == BULLISH AND LTF bias == BULLISH AND Matched was false on the previous bar
Short: on the chart series, close crosses below the latest uncrossed internal pivot low (bearish OB created)
Short: a bearish active OB has Touched true on an earlier bar, has not been retested, and close < its zone low (first time only per OB)
Short: OBBias(chart series) == BEARISH
Short: HTF bias == BEARISH AND LTF bias == BEARISH AND Matched was false on the previous bar