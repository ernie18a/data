Calculation: Confirmed swing high/low = a bar’s high/low is strictly above/below the corresponding highs/lows of the following shorter confirmation window; the swing is confirmed after that window completes.
Calculation: Current structural direction = turns bullish when close crosses above the latest confirmed swing high, and bearish when close crosses below the latest confirmed swing low; otherwise retains its prior direction.
Calculation: Bullish/bearish FVG = a three-bar gap where current low > high two bars earlier / current high < low two bars earlier, with the middle close displaced beyond the middle low/high by the configured ATR(200) threshold; gaps are tracked until invalidated under the configured mitigation rule.
Calculation: Rejected-block pivot = a confirmed pivot low/high whose lower/upper wick is at least the configured share of its candle range and, when enabled, at least the configured multiple of ATR; its zone spans from the wick extreme to the nearest body edge.
Calculation: Confirmed BOSS pivot = a confirmed pivot high/low using its own pivot window, independent of the structural swing window.
Calculation: CHoCH Fibonacci zone = the 0.382–0.618 retracement of the range from the opposite structural level to the CHoCH bar’s extreme.
Calculation: Two-pivot trend line = line from the previous regime’s low/high liquidity extreme to the first post-CHoCH confirmed swing low/high that is higher/lower than that extreme.
Long: Confirmed close crosses above the latest unbroken confirmed swing high (or, if wick breaks are configured, the high crosses above it); this is marked as bullish CHoCH when prior structural direction was bearish, otherwise bullish BOS.
Short: Confirmed close crosses below the latest unbroken confirmed swing low (or, if wick breaks are configured, the low crosses below it); this is marked as bearish CHoCH when prior structural direction was bullish, otherwise bearish BOS.
Long: A confirmed BOSS pivot low is at or above the previous BOSS pivot low (first pivot qualifies).
Short: A confirmed BOSS pivot high is at or below the previous BOSS pivot high (first pivot qualifies).
Long: In bullish structural direction after the latest bullish CHoCH, a qualified rejected-block pivot low forms.
Short: In bearish structural direction after the latest bearish CHoCH, a qualified rejected-block pivot high forms.
Long: After a bullish rejected block is confirmed, price first trades entirely above its zone, then a later bar’s range overlaps the zone.
Short: After a bearish rejected block is confirmed, price first trades entirely below its zone, then a later bar’s range overlaps the zone.
Long: In bullish structural direction, a bullish candle closes above its open, makes a lower low than the prior bar, and overlaps an active bullish FVG.
Short: In bearish structural direction, a bearish candle closes below its open, makes a higher high than the prior bar, and overlaps an active bearish FVG.
Long: After a bullish rejected-block retest, a bullish BOS and a new bullish FVG occur within the configured maximum bar separation.
Short: After a bearish rejected-block retest, a bearish BOS and a new bearish FVG occur within the configured maximum bar separation.
Long: After the qualifying bullish BOS/FVG pair, a later bar touches the final bullish FVG before invalidating it.
Short: After the qualifying bearish BOS/FVG pair, a later bar touches the final bearish FVG before invalidating it.
Long: After a bullish CHoCH, a later bar touches its Fibonacci zone and then a confirmed bar closes above the zone’s upper boundary; only the first such exit is marked.
Short: After a bearish CHoCH, a later bar touches its Fibonacci zone and then a confirmed bar closes below the zone’s lower boundary; only the first such exit is marked.
Long: After a validated bearish two-pivot trend line, a confirmed bar closes (or, if configured, its high crosses) above the line.
Short: After a validated bullish two-pivot trend line, a confirmed bar closes (or, if configured, its low crosses) below the line.