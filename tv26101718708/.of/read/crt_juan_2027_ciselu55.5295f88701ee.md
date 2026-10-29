Calculation: Recent pivot low = low at the latest confirmed pivot low, where a pivot low is lower than the lows over equal left and right lookbacks
Calculation: Recent pivot high = high at the latest confirmed pivot high, where a pivot high is higher than the highs over equal left and right lookbacks
Calculation: Rolling lowest low = lowest low over the left lookback
Calculation: Rolling lowest close = lowest close over the left lookback
Calculation: Rolling highest high = highest high over the left lookback
Calculation: Rolling highest close = highest close over the left lookback
Long: low < recent pivot low AND close > recent pivot low AND open > recent pivot low AND low = rolling lowest low AND rolling lowest close >= recent pivot low
Long: bullish sweep condition was true 3 bars ago AND close > recent pivot low AND close[1] > recent pivot low[1] AND close[2] > recent pivot low[2] AND bars since the previous bullish sweep signal >= the cooldown period
Short: high > recent pivot high AND close < recent pivot high AND open < recent pivot high AND high = rolling highest high AND rolling highest close <= recent pivot high
Short: bearish sweep condition was true 3 bars ago AND close < recent pivot high AND close[1] < recent pivot high[1] AND close[2] < recent pivot high[2] AND bars since the previous bearish sweep signal >= the cooldown period