Trade the chart instrument long or short using a composite market-breadth score built entirely from external data. The score runs 0-100 and is updated once per bar on daily data.

Inputs, all external to the traded instrument:
1. Participation: the percentage of S&P 500 stocks trading above their 200-day moving average. Use a primary breadth series and fall back to a secondary one if the primary is unavailable. The series is already on a 0-100 scale.
2. Momentum: the McClellan Summation Index of NYSE issues. Each bar, take advancing issues minus declining issues. Compute a fast exponential average and a slow exponential average of that difference, and subtract slow from fast to get the McClellan Oscillator. Cumulate the oscillator bar by bar from zero to get the Summation Index. Convert the Summation Index to 0-100 with its percentile rank over roughly one year of bars.
3. Leadership: NYSE new 52-week highs divided by the sum of new highs and new lows, times 100. If both counts are zero, use the neutral value of the 0-100 scale.

Composite score: the weighted average of the three components, with equal weights by default. If participation data is unavailable, average only momentum and leadership with their weights renormalized. Ignore the warm-up period until the percentile rank has a full lookback of history.

Decision rules, evaluated on the composite score at each bar close:
- Go long (or flip from short to long) when the score crosses from below to above the midpoint of the scale. This is the bullish breadth-confirmation signal.
- Go short, or exit the long and stay flat if shorting is not wanted, when the score crosses from above to below the midpoint. This is the bearish deterioration signal.
- Hold the position between crossings.

Optional context, not required for entry or exit:
- A score above a high overbought level means strong breadth, though it can precede a pullback.
- A score below a low oversold level means weak breadth.
- Divergence, where price makes a new high but the score makes a lower high, warns of narrowing participation.
- A fall in participation below a warning level, the sign flip of Summation Index through zero, and leadership crossing its neutral value are supporting alerts for the same bullish or bearish breadth reading.