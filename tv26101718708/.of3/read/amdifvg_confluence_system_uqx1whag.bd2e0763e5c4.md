Calculation: Per-timeframe HTF bias = for each separate T1–T6, run EMA calculations on that timeframe’s bars and sample its current bar on chart bars (possibly forming in real time; lookahead off); add a unit weight with positive sign when close > EMA(close, trend EMA lookback), otherwise negative, and likewise for EMA(close, fast EMA lookback) > EMA(close, slow EMA lookback) and close > EMA(close, fast EMA lookback); fast lookback < slow lookback < trend lookback.
Calculation: Aggregate HTF bias = sum of the six per-timeframe HTF bias scores.
Calculation: Prior T7 midpoint = (high + low) / 2 of the last completed T7 bar, sampled on chart bars.
Calculation: Session-timezone midnight open = the open of the first chart bar in the configured midnight interval, carried forward until the next session day.
Calculation: CVD = sum over the CVD window of volume when close > open, negative volume when close < open, and zero when close = open; calculated on chart bars.
Calculation: Bullish structure break = close > the most recently confirmed PivotHigh(high, swing lookback, swing lookback) and prior close <= that same pivot; classify as CHoCH if the prior structure direction was bearish, otherwise BOS, then set structure direction bullish; initial direction is neutral.
Calculation: Bearish structure break = close < the most recently confirmed PivotLow(low, swing lookback, swing lookback) and prior close >= that same pivot; classify as CHoCH if the prior structure direction was bullish, otherwise BOS, then set structure direction bearish; initial direction is neutral.
Calculation: Bullish liquidity sweep = low < the second-most-recent confirmed PivotLow(low, swing lookback, swing lookback) and close > that pivot, when it exists.
Calculation: Bearish liquidity sweep = high > the second-most-recent confirmed PivotHigh(high, swing lookback, swing lookback) and close < that pivot, when it exists.
Calculation: Bullish fair value gap = current low > high two chart bars earlier, and, when the minimum-size filter is enabled, the gap is at least the minimum FVG size multiplier × ATR(ATR lookback) at formation.
Calculation: Bearish fair value gap = current high < low two chart bars earlier, and, when the minimum-size filter is enabled, the gap is at least the minimum FVG size multiplier × ATR(ATR lookback) at formation.
Calculation: Bullish IFVG flip = current close > the top of a previously formed, not-yet-inverted bearish fair value gap.
Calculation: Bearish IFVG flip = current close < the bottom of a previously formed, not-yet-inverted bullish fair value gap.
Calculation: Bullish confluence score = strong-bias bonus when aggregate HTF bias >= strong-bias threshold; otherwise unit weight when aggregate HTF bias >= mild-bias threshold; otherwise zero; plus unit weight for each true condition: bullish structure break, bullish IFVG flip, bullish liquidity sweep, close < prior T7 midpoint, CVD > its prior chart-bar value, close > session-timezone midnight open when available, current chart bar inside any configured London, NY AM, or NY PM session, and close < close[CVD window] AND CVD > CVD[CVD window].
Calculation: Bearish confluence score = strong-bias bonus when aggregate HTF bias <= negative strong-bias threshold; otherwise unit weight when aggregate HTF bias <= negative mild-bias threshold; otherwise zero; plus unit weight for each true condition: bearish structure break, bearish IFVG flip, bearish liquidity sweep, close > prior T7 midpoint, CVD < its prior chart-bar value, close < session-timezone midnight open when available, current chart bar inside any configured London, NY AM, or NY PM session, and close > close[CVD window] AND CVD < CVD[CVD window].
Long: Any per-timeframe HTF bias score or aggregate HTF bias score >= mild-bias threshold.
Short: Any per-timeframe HTF bias score or aggregate HTF bias score <= negative mild-bias threshold.
Long: Bullish confluence score > bearish confluence score.
Short: Bearish confluence score > bullish confluence score.
Long: Bullish confluence score >= minimum confluence score AND bullish confluence score > bearish confluence score.
Short: Bearish confluence score >= minimum confluence score AND bearish confluence score > bullish confluence score.
Long: Bullish structure break classified as BOS.
Long: Bullish structure break classified as CHoCH.
Short: Bearish structure break classified as BOS.
Short: Bearish structure break classified as CHoCH.
Long: Bullish fair value gap.
Short: Bearish fair value gap.
Long: Bullish IFVG flip.
Short: Bearish IFVG flip.
Long: Bullish liquidity sweep.
Short: Bearish liquidity sweep.