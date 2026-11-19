Calculation: Consolidation high = highest high during each consolidation window, reset daily
Calculation: Consolidation low = lowest low during each consolidation window, reset daily
Calculation: Long stop = low of the bar before entry, held until exit
Calculation: Long target = entry price + (entry price − long stop) × R:R parameter, held until exit
Calculation: Short stop = high of the bar before entry, held until exit
Calculation: Short target = entry price − (short stop − entry price) × R:R parameter, held until exit
Long: consolidation window complete AND within trading window AND flat AND close > consolidation high AND close > EMA(close, lookback) AND close > low[1] AND daily entry count < daily trade limit
Short: consolidation window complete AND within trading window AND flat AND close < consolidation low AND close < EMA(close, lookback) AND close < high[1] AND daily entry count < daily trade limit
Exit: long, close < EMA(close, lookback) OR low ≤ long stop OR high ≥ long target
Exit: short, close > EMA(close, lookback) OR high ≥ short stop OR low ≤ short target