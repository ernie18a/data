Calculation: Stop source = a selected price source; use high and low as the upper and lower test prices when wick testing is enabled, otherwise use close for both.
Calculation: Trailing stops = on each bar, set raw long stop to stop source minus an ATR multiple and raw short stop to stop source plus the same ATR multiple. For each stop, use its preceding final value as the previous stop, or its current raw value if the preceding value is unavailable. If the raw stop is nonpositive or open = high = low = close, retain its previous stop. Otherwise, if the preceding lower test price > previous long stop, set the long stop to the greater of its raw and previous values; otherwise use its raw value. If the preceding upper test price < previous short stop, set the short stop to the lesser of its raw and previous values; otherwise use its raw value.
Calculation: Stop direction = initialize long; on each bar change from short to long if the upper test price > the previous short stop, or from long to short if the lower test price < the previous long stop; otherwise retain the preceding direction.
Calculation: Trend average = SMA of a selected price source, calculated either on the chart timeframe or on a selected different timeframe. For a higher timeframe, historical bars use the last completed higher-timeframe bar and a realtime bar can use the still-forming bar; for a lower timeframe, historical bars use the last available intrabar and realtime bars use the latest available intrabar.
Calculation: Channel = trend average plus and minus a multiple of chart-timeframe ATR, with the ATR lookback equal to the trend SMA lookback. Price is in the channel when (open <= upper boundary OR close <= upper boundary) AND (open >= lower boundary OR close >= lower boundary).
Calculation: Trend direction = neutral if price is in the channel; otherwise long if the selected EMA source >= trend average, and short if the selected EMA source < trend average.
Calculation: EMA decision state = initialize neutral. On each bar, set long if the previous state is not long AND trend direction is long AND shorter EMA > longer EMA; otherwise set short if the previous state is not short AND trend direction is short AND shorter EMA < longer EMA; otherwise set neutral if the previous state is not neutral AND ((trend direction is long AND shorter EMA < longer EMA) OR (trend direction is short AND shorter EMA > longer EMA)); otherwise retain the previous state. Both EMAs use the selected EMA source.
Long: Stop direction changes from short to long.
Short: Stop direction changes from long to short.
Long: Stop direction = long.
Short: Stop direction = short.
Long: Trend direction = long.
Short: Trend direction = short.
Long: EMA decision state = long AND previous EMA decision state != long.
Short: EMA decision state = short AND previous EMA decision state != short.
Long: Longer EMA crosses above trend average.
Short: Longer EMA crosses below trend average.
Exit: long, previous EMA decision state != neutral AND ((trend direction = long AND shorter EMA < longer EMA) OR (trend direction = short AND shorter EMA > longer EMA)).
Exit: short, previous EMA decision state != neutral AND ((trend direction = long AND shorter EMA < longer EMA) OR (trend direction = short AND shorter EMA > longer EMA)).