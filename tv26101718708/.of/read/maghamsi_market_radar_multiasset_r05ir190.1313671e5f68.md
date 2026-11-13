Calculation: TrendEMA = exponential moving average of close with a long lookback (longer than the momentum lookback)
Calculation: Mom = linear regression value at the current bar (zero offset) over the momentum lookback of [close - average(average(highest high over the momentum lookback, lowest low over the momentum lookback), simple moving average of close over the momentum lookback)]
Calculation: Surge = close > open AND close > previous bar's high AND volume > (a multiple greater than 1) * simple moving average of volume
Long: (close > TrendEMA AND Mom > 0) OR Surge OR (Mom > 0 AND Mom > previous bar's Mom)
Short: close < TrendEMA AND NOT Surge AND NOT (Mom > 0 AND Mom > previous bar's Mom)