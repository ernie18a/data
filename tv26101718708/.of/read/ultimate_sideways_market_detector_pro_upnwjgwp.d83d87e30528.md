Calculation: ADX = Wilder ADX
Calculation: ATR = Wilder average true range; ATRavg = longer-term simple average of ATR
Calculation: EMA = exponential moving average of close
Calculation: RangeHigh/RangeLow = highest high / lowest low over the range lookback
Calculation: Sideways = weighted score of enabled conditions >= score threshold; conditions: ADX < low-ADX level; Choppiness Index > high-chop level; ATR < fraction (<1) of ATRavg; Bollinger bandwidth ((upper-lower)/middle band) < fraction (<1) of its longer-term simple average; abs(EMA - EMA lagged several bars) < ATR; (RangeHigh - RangeLow) < multiple of ATR; optional: volume < its simple average
Long: Sideways is false AND Sideways was true on the previous bar AND close > previous bar's RangeHigh
Short: Sideways is false AND Sideways was true on the previous bar AND close < previous bar's RangeLow
Long: Sideways is false AND ADX > strong-trend level (higher than the low-ADX level used in Sideways) AND close > EMA
Short: Sideways is false AND ADX > strong-trend level (higher than the low-ADX level used in Sideways) AND close < EMA