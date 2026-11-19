Calculation: Base volatility = standard deviation(source, sampling lookback), ATR(sampling lookback), or standard deviation(source, sampling lookback) * standard-deviation weight + ATR(sampling lookback) * complement of standard-deviation weight, according to volatility mode
Calculation: Base range multiplier = piecewise-linear interpolation of the range-level parameter, clamped to the first and last range-level anchors, through separately parameterized range-level/multiplier anchor pairs ending at the outer-band multiplier
Calculation: Range 8 multiplier = if scaling is enabled, outer-band multiplier * (base range multiplier / outer-band multiplier) ^ expansion-strength parameter; otherwise, (clamped range level / last range-level anchor) * outer-band multiplier * expansion-strength parameter
Calculation: Range 8 deviation = if volatility mode is percentile, highest(abs(source - selected moving average(source, sampling lookback)), percentile lookback), unchanged when scaling is enabled and otherwise multiplied by expansion-strength parameter; otherwise, selected moving average(base volatility, volatility smoothing lookback, volatility smoothing type) * Range 8 multiplier
Calculation: Range 8 upper band = selected moving average(source, sampling lookback) + Range 8 deviation
Calculation: Range 8 lower band = selected moving average(source, sampling lookback) - Range 8 deviation
Calculation: Bull filters = (RSI filter disabled OR RSI(source, RSI lookback) >= bullish RSI threshold) AND (trend filter disabled OR close >= EMA(source, trend lookback)) AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume factor)
Calculation: Bear filters = (RSI filter disabled OR RSI(source, RSI lookback) <= bearish RSI threshold) AND (trend filter disabled OR close <= EMA(source, trend lookback)) AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume factor)
Calculation: Candle body = max(abs(close - open), minimum price increment)
Calculation: Upper rejection candle = high - max(open, close) >= Candle body * wick-to-body ratio AND close < open
Calculation: Lower rejection candle = min(open, close) - low >= Candle body * wick-to-body ratio AND close > open
Long: close crosses above Range 8 upper band AND (alert filters disabled OR Bull filters)
Long: low < Range 8 lower band AND close > Range 8 lower band AND close < selected moving average(source, sampling lookback) AND (alert filters disabled OR (Bull filters AND (candle rejection filter disabled OR Lower rejection candle)))
Long: close crosses above selected moving average(source, sampling lookback) AND (alert filters disabled OR Bull filters)
Short: close crosses below Range 8 lower band AND (alert filters disabled OR Bear filters)
Short: high > Range 8 upper band AND close < Range 8 upper band AND close > selected moving average(source, sampling lookback) AND (alert filters disabled OR (Bear filters AND (candle rejection filter disabled OR Upper rejection candle)))
Short: close crosses below selected moving average(source, sampling lookback) AND (alert filters disabled OR Bear filters)