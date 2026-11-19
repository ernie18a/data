Calculation: T1 volume EMA = EMA(volume(T1, bar still forming), T1-volume lookback, chart bars)
Calculation: Abnormal volume threshold = max((threshold intercept + threshold log coefficient × ln(T1 volume EMA)) × T1 volume EMA / (T1 duration in minutes / chart interval in minutes), minimum volume threshold)
Calculation: Upper band = VWMA(close, band lookback, T1, bar still forming) + band multiplier × STDEV(close, band lookback, T1, bar still forming)
Calculation: Lower band = VWMA(close, band lookback, T1, bar still forming) − band multiplier × STDEV(close, band lookback, T1, bar still forming)
Calculation: Bearish volume signal = volume[core lookback] > Abnormal volume threshold[core lookback] AND close[core lookback] < open[core lookback]
Calculation: Bullish volume signal = volume[core lookback] > Abnormal volume threshold[core lookback] AND close[core lookback] > open[core lookback]
Long: chart bar confirmed AND position flat AND ((Bearish volume signal AND close(T1, bar still forming) > Upper band) OR (reversal trading enabled AND SUM(Bullish volume signal, reversal lookback, chart bars) >= reversal count threshold AND close(T1, bar still forming) > Upper band))
Short: chart bar confirmed AND position flat AND ((Bullish volume signal AND close(T1, bar still forming) < Lower band) OR (reversal trading enabled AND SUM(Bearish volume signal, reversal lookback, chart bars) >= reversal count threshold AND close(T1, bar still forming) < Lower band))
Exit: Long, low <= low[core lookback] captured at entry × (1 − normal stop-loss buffer percentage / 100) OR high >= high[core lookback] captured at entry × (1 + normal take-profit buffer percentage / 100)
Exit: Long, low <= entry price × (1 − reversal stop distance / 100) OR high >= entry price × (1 + reversal take-profit distance / 100)
Exit: Short, high >= high[core lookback] captured at entry × (1 + normal stop-loss buffer percentage / 100) OR low <= low[core lookback] captured at entry × (1 − normal take-profit buffer percentage / 100)
Exit: Short, high >= entry price × (1 + reversal stop distance / 100) OR low <= entry price × (1 − reversal take-profit distance / 100)