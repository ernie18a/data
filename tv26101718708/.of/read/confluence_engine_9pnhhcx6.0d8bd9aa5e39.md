Calculation: Dealing-range midpoint = midpoint of the running high and low of the current, still-forming higher-timeframe period.
Calculation: Midnight open = open of the first lower-timeframe bar beginning in the midnight hour of the configured session timezone; use the chart bar instead when the chart timeframe is no higher than the session source timeframe.
Calculation: Confirmed swing high or low = a pivot high or low using the configured numbers of chart bars to its left and right; it becomes available only after the right-hand bars close. Each newly confirmed swing replaces the previous swing on that side and may be broken once.
Long: Bullish votes exceed bearish votes, where one bullish vote is close < midnight open, one bearish vote is close > midnight open, one bullish vote is close < dealing-range midpoint, and one bearish vote is close > dealing-range midpoint.
Short: Bearish votes exceed bullish votes, using the same vote comparisons.
Long: Midnight open is available AND close < midnight open.
Short: Midnight open is available AND close >= midnight open.
Long: Close > the latest confirmed swing high AND that swing has not previously been closed above.
Short: Close < the latest confirmed swing low AND that swing has not previously been closed below.
Long: Low > high two bars earlier AND low minus that earlier high >= ATR multiplied by the gap-height threshold AND the previous bar closes above its open AND its body size >= current ATR multiplied by the displacement threshold.
Short: High < low two bars earlier AND that earlier low minus high >= ATR multiplied by the gap-height threshold AND the previous bar closes below its open AND its body size >= current ATR multiplied by the displacement threshold.
Long: Each of the current and previous two bars closes above its open AND each of the last two opens > the preceding close AND both bar-time gaps are within the continuity threshold AND current open minus the close two bars earlier >= ATR multiplied by the gap-height threshold.
Short: Each of the current and previous two bars closes below its open AND each of the last two opens < the preceding close AND both bar-time gaps are within the continuity threshold AND the close two bars earlier minus current open >= ATR multiplied by the gap-height threshold.