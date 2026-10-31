Calculation: Trend value for a price series = (shorter-period moving average of the series − longer-period moving average of the series) × a separately parameterized moving average of the same series; the first two use the same smoothing method, while the third may use another method.
Calculation: Trend candle open = previous bar's trend candle close if abs(open − previous close) < gap threshold; otherwise the trend value of open. Initialize the previous trend candle close to zero.
Calculation: Trend candle close = trend value of close.
Long: Trend candle close >= trend candle open.
Short: Trend candle close < trend candle open.
Long: Higher-timeframe trend candle close >= higher-timeframe trend candle open, using the higher-timeframe bar still forming.
Short: Higher-timeframe trend candle close < higher-timeframe trend candle open, using the higher-timeframe bar still forming.