Calculation: Entry EMA 1 = EMA of close with length L1, computed on bars of a timeframe higher than the chart timeframe (the longer-term chain), using the bar still forming at the current chart bar
Calculation: Exit EMA 1 = EMA of close with the same length L1 as Entry EMA 1, computed on bars of a timeframe lower than Entry EMA 1's timeframe but still higher than the chart timeframe, using the bar still forming
Calculation: Entry EMA 2 = EMA of close with length L2, computed on bars of a timeframe higher than the chart timeframe and lower than Entry EMA 1's timeframe (the shorter-term chain), using the bar still forming
Calculation: Exit EMA 2 = EMA of close with the same length L2 as Entry EMA 2, computed on bars of a timeframe lower than Entry EMA 2's timeframe but still higher than the chart timeframe, using the bar still forming
Long: chart close crosses above Entry EMA 1 (previous close <= previous Entry EMA 1 AND current close > current Entry EMA 1) OR chart close crosses above Entry EMA 2 (same crossover test); the two chains are independent and each opens its own long position
Short: chart close crosses below Entry EMA 1 (previous close >= previous Entry EMA 1 AND current close < current Entry EMA 1) OR chart close crosses below Entry EMA 2 (same crossover test); the two chains are independent and each opens its own short position
Exit: long opened by chain 1, chart close crosses below Exit EMA 1
Exit: short opened by chain 1, chart close crosses above Exit EMA 1
Exit: long opened by chain 2, chart close crosses below Exit EMA 2
Exit: short opened by chain 2, chart close crosses above Exit EMA 2