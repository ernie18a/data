Calculation: sessionAverage = arithmetic mean of HLC3 over the latest up to average lookback chart bars since the current T1 period began
Calculation: sessionRange = maximum HLC3 minus minimum HLC3 over those same chart bars
Calculation: slopePercent = 100 × (EMA(sessionAverage, smoothing lookback) − EMA(sessionAverage, smoothing lookback)[slope lookback]) / EMA(sessionAverage, smoothing lookback)[slope lookback], defined when more than slope lookback chart bars have elapsed in the current T1 period and the lagged EMA exists
Calculation: compressionPercent = 100 × sessionRange / sessionAverage, defined when sessionAverage is not zero
Calculation: rawMomentum = (HLC3 − sessionAverage) / sessionRange when sessionRange is not zero, otherwise 0
Calculation: momentum = EMA(rawMomentum, smoothing lookback)
Calculation: sidewaysConfirmed = the count of consecutive chart bars since the second chart bar of the current T1 period, each with at least minimum session bars elapsed, defined slopePercent whose absolute value is at most the maximum slope for sideways parameter, and defined compressionPercent at most the maximum compression range parameter, is at least the sideways confirmation lookback; the count resets on the first chart bar of each T1 period or when any condition fails
Long: sidewaysConfirmed is false AND momentum > bullish threshold
Short: sidewaysConfirmed is false AND momentum < bearish threshold