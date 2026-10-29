Calculation: Raw upper band = LWMA of high × (1 + percentage shift) + ATR × sensitivity
Calculation: Raw lower band = LWMA of low × (1 − percentage shift) − ATR × sensitivity
Calculation: Upper trend band = while bearish, the lower of the raw upper band and the prior upper trend band; otherwise the raw upper band
Calculation: Lower trend band = while bullish, the higher of the raw lower band and the prior lower trend band; otherwise the raw lower band
Calculation: Trend state = bullish when close > prior upper trend band; bearish when close < prior lower trend band; otherwise retain the prior state
Calculation: For the higher-timeframe version, calculate these values from aggregated bars on a higher timeframe, using the still-forming bar; carry the trend bands forward between higher-timeframe bar starts
Long: close > prior upper trend band AND prior trend state was not bullish
Short: close < prior lower trend band AND prior trend state was not bearish