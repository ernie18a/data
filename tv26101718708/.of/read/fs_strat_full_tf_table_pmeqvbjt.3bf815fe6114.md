Calculation: Bullish alignment count = number of enabled timeframes whose current bar high > previous bar high AND current bar low >= previous bar low.
Calculation: Bearish alignment count = number of enabled timeframes whose current bar high <= previous bar high AND current bar low < previous bar low.
Calculation: For each enabled timeframe, use the chart bar when timeframes match, the bar still forming when the timeframe is higher, and the last available completed bar when the timeframe is lower; compare it with the preceding bar of that timeframe.
Long: Bullish alignment count > 0.
Short: Bearish alignment count > 0.
Long: Bullish alignment count >= minimum alignment count.
Short: Bearish alignment count >= minimum alignment count.