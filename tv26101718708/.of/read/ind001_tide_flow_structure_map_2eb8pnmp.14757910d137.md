Calculation: Trend EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Upper structure = EMA-smoothed rolling highest high
Calculation: Lower structure = EMA-smoothed rolling lowest low
Calculation: Risk line = the higher of the lower structure and the running maximum, since entry, of close minus ATR times a multiplier
Long: At a completed chart bar, the long gates are true AND (close > the previous bar's upper structure OR low <= fast EMA AND close > fast EMA OR close crosses above fast EMA) AND no long signal occurred within the cooldown lookback; long gates are close > trend EMA AND fast EMA > trend EMA AND trend EMA is rising AND higher-timeframe close > its 200-period EMA using the last completed higher-timeframe bar AND ADX >= threshold AND ATR / close * 100 >= threshold AND RSI <= threshold AND fast EMA's percentage change from the prior bar >= negative slope threshold
Long: All long gates are true AND close > fast EMA AND close > trend EMA
Long: At a completed chart bar, close crosses above the upper structure AND all long gates are true
Exit: Long, close is below the risk line on at least the required number of consecutive completed chart bars