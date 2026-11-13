Long-only entry signal evaluated on each bar's close. There is no short logic and no exit logic. The swing-low stop level is only plotted as a reference and does not trigger exits. Go long when ALL of the following hold at once.

1. Trend template (stage-2 uptrend filter), using simple moving averages of close at short, intermediate and long lengths, plus the trailing one-year high and low:
- Close is above both the intermediate and long moving averages.
- The intermediate average is above the long average.
- The long average is higher than it was a set number of bars ago, so it is rising.
- The short average is above both the intermediate and long averages.
- Close is above the short average.
- Close is within a set fraction of the trailing one-year highest high, so it is near the high.
- Close is at least a set percentage above the trailing one-year lowest low.

2. Relative strength against an external benchmark index. Fetch the index close on the same timeframe, and compute the relative-strength line as instrument close divided by index close. It must satisfy both of these:
- The line is above its own moving average.
- The line is above its value a set number of bars ago.

3. Volatility contraction. Both of these must hold:
- The recent range (highest high minus lowest low over a short window) is smaller than a set fraction of the range over a longer window.
- ATR as a percent of close is below its own moving average.

4. Not extended. The percentage distance of close above the short moving average must be at or below a maximum.

5. Breakout. Close is above the highest high of the previous N bars, excluding the current bar.

6. Volume confirmation. Current volume exceeds a multiple of its moving average of volume.

Conditions 1 to 4 together form a candidate setup. The buy signal fires when a candidate coincides with both the breakout (5) and the volume confirmation (6).