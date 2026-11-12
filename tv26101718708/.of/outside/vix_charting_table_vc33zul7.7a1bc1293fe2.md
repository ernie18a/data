Use VIX (an outside instrument) as a directional regime gate for index futures. Compute a VIX 'trend-range-filter line' on 15-minute VIX bars, then compare the live VIX price to the last confirmed value of that line.

Line construction (on VIX closes, per 15-minute bar):
1. Build a smoothed range for each of two settings (fast and slow). Take the EMA of the absolute bar-to-bar change in close, smooth that with a second, longer EMA (length 2*period-1), and multiply by the setting's multiplier. Average the two results into one range value r.
2. Build a range filter. Start from the close. If the close is above the previous filter value, set the filter to max(previous filter, close - r). Otherwise set it to min(previous filter, close + r).
3. Build ratcheting bands around the filter. Candidate upper = filter + r and candidate lower = filter - r. The final upper band takes the candidate only if the candidate is below the previous final upper or the previous close was above the previous final upper. Otherwise it keeps its previous value. The final lower band takes the candidate only if the candidate is above the previous final lower or the previous close was below the previous final lower. Otherwise it keeps its previous value.
4. The line is a supertrend-style switch between the two final bands. If the previous line was the upper band, the line stays on the upper band while close <= upper and switches to the lower band when close > upper. If the previous line was the lower band, it stays on the lower band while close >= lower and switches to the upper band when close < lower. Default to the upper band when undefined.

No-lookahead rule: use only the line value from the previous completed 15-minute VIX bar. The line updates once per 15-minute close. Take the live VIX price from the chart's own timeframe (updates every bar). If that is unavailable, fall back to the previous completed 15-minute VIX close. Evaluate on every chart bar, and require both values to exist.

Decision:
- VIX price > confirmed 15-minute line: risk-off. Short bias. Block or avoid longs, and exit any long.
- VIX price <= confirmed 15-minute line: risk-on. Long bias. Block or avoid shorts, and exit any short.
- The regime flips on the first bar where the comparison changes sign. A flip to above favors going short or exiting longs. A flip to below favors going long or exiting shorts.
- Optional fast-exit warning: compute the same line on 5-minute VIX bars, again using the previous completed bar's value. VIX price crossing above it is an early risk-off signal.