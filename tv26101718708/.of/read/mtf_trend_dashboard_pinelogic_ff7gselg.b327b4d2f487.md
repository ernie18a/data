Calculation: Trend value for each configured timeframe = +1 when that timeframe’s close is above its slow EMA and its fast EMA is above its slow EMA; −1 when its close is below its slow EMA and its fast EMA is below its slow EMA; otherwise 0. Use the timeframe data returned by the timeframe request: higher-timeframe values use the bar still forming; lower-timeframe values use the bar selected by the request.
Calculation: Trend score = sum of the five configured timeframe trend values.
Long: Trend score >= 3
Short: Trend score <= -3