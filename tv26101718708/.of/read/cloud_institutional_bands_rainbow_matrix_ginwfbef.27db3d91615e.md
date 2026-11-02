Calculation: Typical price = (high + low + close) / 3.
Calculation: Regression base = exponential of the current endpoint of a rolling linear regression of the natural logarithm of typical price.
Calculation: Log deviation = rolling population standard deviation, over the same lookback as the regression, of the series formed by subtracting each bar's regression endpoint from that bar's log typical price, floored at a small positive value.
Calculation: Standardized value of x = natural logarithm of x divided by the regression base, divided by log deviation; use zero when x or log deviation is nonpositive.
Calculation: Outer upper and lower bands = exponential of the current log regression endpoint plus and minus, respectively, log deviation multiplied by the outer deviation threshold. The outer threshold is larger than the alert threshold.
Calculation: Rolling VWMA = volume-weighted moving average of typical price over the regression lookback. The regression, deviation, bands, and rolling VWMA use the chart timeframe or an aggregated timeframe: for a higher timeframe use its last completed bar; for a lower timeframe use its last completed constituent bar within the chart bar.
Calculation: Anchored VWAP = cumulative sum of typical price multiplied by volume divided by cumulative volume since the start of a recurring higher-timeframe anchor period.
Long: close > rolling VWMA OR close > anchored VWAP OR high > rolling VWMA.
Short: close <= rolling VWMA OR close <= anchored VWAP OR (high <= rolling VWMA AND low < rolling VWMA).
Long: standardized value of typical price < negative alert threshold OR standardized value of rolling VWMA < negative alert threshold OR low <= outer lower band.
Short: standardized value of typical price >= alert threshold OR standardized value of rolling VWMA >= alert threshold OR high >= outer upper band.