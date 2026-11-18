Calculation: stock return = (close − close the configured lookback bars ago) × 100 / close
Calculation: index return = (daily index close − daily index close the configured lookback bars ago) × 100 / daily index close; use the daily bar still forming
Calculation: relative return = stock return − index return
Calculation: stock-return moving average = selected moving average of stock return over the configured length
Calculation: index-return moving average = selected moving average of index return over the configured length
Calculation: relative-return moving average = selected moving average of relative return over the configured length
Long: stock-return moving average > index-return moving average AND datetime is within the configured date range
Long: stock return > index return AND datetime is within the configured date range
Long: relative return > relative-return moving average AND datetime is within the configured date range
Exit: long, stock-return moving average < index-return moving average
Exit: long, stock return < index return
Exit: long, relative return < relative-return moving average