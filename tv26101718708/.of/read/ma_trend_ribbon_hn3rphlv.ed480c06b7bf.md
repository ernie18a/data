Calculation: Fast and slow moving averages = the same selected moving-average type applied to a selected OHLC-derived source, with the slow length equal to the fast length plus five equal spacing increments; calculate on the chart timeframe or a higher timeframe. For a higher timeframe, use the last completed bar on historical chart bars and the still-forming bar in real time; map each result to the chart bars.
Calculation: Trend difference = either the fast moving average minus the slow moving average, or the fast moving average minus its value on the previous chart bar, according to the selected trigger.
Long: Trend difference > 0
Short: Trend difference <= 0
Exit: long, trend difference <= 0 AND previous chart bar's trend difference > 0
Exit: short, trend difference > 0 AND previous chart bar's trend difference <= 0