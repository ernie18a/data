Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Target high = high of the most recently completed session in sequence: Asian, then London, then New York; reset at the start of the next Asian session until the Asian session completes
Calculation: Target low = low of the most recently completed session in sequence: Asian, then London, then New York; reset at the start of the next Asian session until the Asian session completes
Calculation: Last sweep high = high of the most recent bar since the current Asian session started where high > target high, close < target high, and volume > average volume × threshold; clear after close exceeds it
Calculation: Last sweep low = low of the most recent bar since the current Asian session started where low < target low, close > target low, and volume > average volume × threshold; clear after close falls below it
Short: high > target high AND close < target high AND volume > average volume × threshold
Short: close < last sweep low
Long: low < target low AND close > target low AND volume > average volume × threshold
Long: close > last sweep high