Calculation: MA1 = selected moving average of its selected source over its lookback on its selected timeframe, using the last completed bar; its type, timeframe, source, and lookback are independently configurable from MA2
Calculation: MA2 = selected moving average of its selected source over its lookback on its selected timeframe, using the last completed bar; its type, timeframe, source, and lookback are independently configurable from MA1
Long: MA1 crosses above MA2 AND current bar is confirmed AND position is flat
Short: MA1 crosses below MA2 AND current bar is confirmed AND position is flat
Calculation: Long stop = low of the bar before entry
Calculation: Short stop = high of the bar before entry
Calculation: Long target = entry price + (entry price − long stop) × risk-to-reward ratio
Calculation: Short target = entry price − (short stop − entry price) × risk-to-reward ratio
Exit: long, bar low ≤ long stop OR bar high ≥ long target
Exit: short, bar high ≥ short stop OR bar low ≤ short target