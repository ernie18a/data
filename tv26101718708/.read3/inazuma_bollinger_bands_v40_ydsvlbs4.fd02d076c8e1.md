Calculation: Upper band = SMA(source, lookback) + outer multiplier × standard deviation(source, lookback)
Calculation: Lower band = SMA(source, lookback) − outer multiplier × standard deviation(source, lookback)
Calculation: Upper inner band = SMA(source, lookback) + inner multiplier × standard deviation(source, lookback)
Calculation: Lower inner band = SMA(source, lookback) − inner multiplier × standard deviation(source, lookback)
Calculation: Up squeeze = high <= Upper band AND low > Upper inner band AND (high[1] > Upper band[1] OR Up squeeze[1])
Calculation: Down squeeze = low >= Lower band AND high < Lower inner band AND (low[1] < Lower band[1] OR Down squeeze[1])
Long: high > Upper band
Long: Up squeeze
Short: low < Lower band
Short: Down squeeze