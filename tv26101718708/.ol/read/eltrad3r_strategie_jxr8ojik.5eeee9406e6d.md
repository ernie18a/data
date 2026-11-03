Calculation: Consolidation high = highest high during the current day's consolidation window
Calculation: Consolidation low = lowest low during the current day's consolidation window
Calculation: Long stop = previous bar low
Calculation: Short stop = previous bar high
Calculation: Long target = entry price + (entry price − long stop) × minimum configured risk/reward ratio
Calculation: Short target = entry price − (short stop − entry price) × minimum configured risk/reward ratio
Long: consolidation window is complete AND datetime is within the trading window AND no position is open AND daily trade count < configured maximum AND close > consolidation high AND close > EMA AND close > previous bar low
Short: consolidation window is complete AND datetime is within the trading window AND no position is open AND daily trade count < configured maximum AND close < consolidation low AND close < EMA AND close < previous bar high
Exit: long, close < EMA OR low ≤ long stop OR high ≥ long target
Exit: short, close > EMA OR high ≥ short stop OR low ≤ short target