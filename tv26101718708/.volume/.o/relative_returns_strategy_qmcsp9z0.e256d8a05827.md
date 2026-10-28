Calculation: Stock return = (current close − close from the lookback bars ago) × 100 ÷ current close
Calculation: Index return = (current daily index close − daily index close from the lookback bars ago) × 100 ÷ current daily index close; use the daily bar still forming
Calculation: Relative return = stock return − index return
Long: (moving average of stock return > moving average of index return OR stock return > index return OR relative return > moving average of relative return) AND time >= start time AND time <= end time
Exit: long, moving average of stock return < moving average of index return OR stock return < index return OR relative return < moving average of relative return