Calculation: RSI pivot = a pivot high or low of close-based RSI using configurable left and right lookbacks, confirmed after the right lookback; its price is the high/low or the maximum/minimum of open and close at the RSI pivot bar, according to the selected price source.
Calculation: Breakout hit rates = for each prior-bar direction, maintain separate percentages for current high reaching the preceding high and current low reaching the preceding low. Count preceding bars with close above open as up bars and those with close below open as down bars. Update a percentage only when its corresponding level is reached, dividing its cumulative hit count by the cumulative count of preceding bars of that direction; initialize percentages to zero. For a preceding doji, use the down-bar percentages.
Calculation: ZigZag pivot = a current high equal to the highest high of the trailing lookback or a current low equal to the lowest low of that lookback. Retain the current direction when both or neither occur; otherwise use the direction of the new extreme. On a direction change, append the extreme; in the same direction, replace the latest pivot only with a more extreme value. Classify the new or replacement pivot against the preceding pivot of the same direction, using strict greater-than for a higher high and strict less-than for a lower low; equality is a lower high or higher low.
Calculation: Swing pivot = a bar whose high is at least as high as, or whose low is at least as low as, every bar in equal-length windows on both sides. Confirm after the right window completes; if both are pivots, select the high. Apply separately to the chart timeframe and to each selected higher timeframe using completed higher-timeframe bars.
Long: Close crosses above both the shorter-period and longer-period close EMAs on the same bar.
Short: Close crosses below both the shorter-period and longer-period close EMAs on the same bar.
Long: The shorter-period close EMA crosses above the longer-period close EMA.
Short: The shorter-period close EMA crosses below the longer-period close EMA.
Long: The shorter-period close EMA is above the longer-period close EMA.
Short: The shorter-period close EMA is less than or equal to the longer-period close EMA.
Long: For a selected higher or lower timeframe, the shorter-period close EMA is above the longer-period close EMA; on historical chart bars use the last completed higher-timeframe bar or the last lower-timeframe bar within the chart bar, and on a forming chart bar use the available forming higher-timeframe bar or latest available lower-timeframe bar.
Short: For a selected higher or lower timeframe, the shorter-period close EMA is less than or equal to the longer-period close EMA; use the same bar selection as the corresponding long condition.
Long: Chart close is above any selected close EMA calculated on a higher or lower timeframe, using the same bar selection as the other multi-timeframe EMA conditions.
Short: Chart close is less than or equal to any selected close EMA calculated on a higher or lower timeframe, using the same bar selection as the other multi-timeframe EMA conditions.
Long: Close-based RSI on a selected higher or lower timeframe is at or above the bullish threshold, using the same bar selection as the multi-timeframe EMA conditions.
Short: Close-based RSI on a selected higher or lower timeframe is at or below the bearish threshold, using the same bar selection as the multi-timeframe EMA conditions.
Long: The breakout high hit rate is greater than or equal to the breakout low hit rate for the preceding bar's direction.
Short: The breakout high hit rate is less than the breakout low hit rate for the preceding bar's direction.
Long: A ZigZag pivot is a higher high or higher low.
Short: A ZigZag pivot is a lower high or lower low.
Long: A newly confirmed RSI pivot low is within the inclusive configured distance range of the preceding RSI pivot low AND its price is lower and RSI is higher, OR its price is higher and RSI is lower.
Short: A newly confirmed RSI pivot high is within the inclusive configured distance range of the preceding RSI pivot high AND its price is higher and RSI is lower, OR its price is lower and RSI is higher.
Long: At least the configured minimum bars have elapsed since the latest confirmed RSI pivot low AND current price low is lower and current RSI is higher than at that pivot, OR current price low is higher and current RSI is lower than at that pivot.
Short: At least the configured minimum bars have elapsed since the latest confirmed RSI pivot high AND current price high is higher and current RSI is lower than at that pivot, OR current price high is lower and current RSI is higher than at that pivot.
Long: A swing pivot low is confirmed.
Short: A swing pivot high is confirmed.