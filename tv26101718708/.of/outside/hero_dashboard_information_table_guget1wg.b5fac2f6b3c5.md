Instrument: an index, on intraday bars. The only decisions are buying a call option, buying a put option, or doing nothing. No short/long on the underlying and no exit rule exist. Option selling is never used.

Inputs, all from the index's own bars:
- Session VWAP and a medium-length EMA of close.
- Average volume over a lookback window.
- ATR, and a longer smoothing of ATR (its own moving average).
- Previous day's high and low.
- Opening range: the high and low of the first 15 minutes of the session, reset each day. It is undefined until the first bar of the day, and fixed after the opening window ends.

Step 1, momentum score. It is an additive score. Each condition adds its own fixed weight when true, and zero otherwise. The VWAP condition has the largest weight, the opening-range breakout the next largest, and the prior-day breakout the third largest. Volume surge and volatility expansion have the smallest weights. The conditions are:
1. Close is above VWAP. This is one-sided, so it only ever helps bullish setups.
2. Current volume is well above its average (a surge multiple).
3. Close is beyond the previous day's high or beyond the previous day's low (either side counts, not direction-specific).
4. Close is beyond the opening range, above its high or below its low (either side counts). This requires the opening range to exist.
5. Current ATR is above its own smoothed average.
The score counts as strong when it reaches a high threshold close to the maximum. Because the weights are asymmetric, a bearish setup cannot collect the VWAP points and needs nearly all the other conditions to reach the threshold. A bullish setup can reach it more easily.

Step 2, trend direction.
- Bullish: close is above both the EMA and VWAP.
- Bearish: close is below both the EMA and VWAP.
- Otherwise neutral.

Step 3, setup flags, evaluated on every bar.
- Bull setup: score is strong AND direction is bullish.
- Bear setup: score is strong AND direction is bearish.

Step 4, trade decision.
- Buy a call option when the bull setup is true. If close is also above the opening-range high, that is only extra confirmation. It does not change the outcome.
- Buy a put option when the bear setup is true. Likewise, close below the opening-range low does not change the outcome.
- Otherwise take no trade (wait). This covers a neutral direction or a weak or moderate score.
- Confidence is only a label derived from the score: high at the strong threshold, medium at a lower threshold, low below that. It does not gate trades beyond the strong-score requirement.

Step 5, option strike suggestion, informational.
- At-the-money strike: spot rounded to the nearest strike increment.
- Expected move: ATR times a multiplier, rounded.
- Strike offset: the expected move converted to a whole number of strike increments, with a minimum of one increment.
- Call strike: at-the-money plus the offset. Put strike: at-the-money minus the offset.