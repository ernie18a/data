Calculation: Modified Hull average = WMA(3 × WMA(close, lookback/6) − WMA(close, lookback/4) − WMA(close, lookback/2), lookback/2)
Calculation: Price average = if Kahlman filtering is enabled, Kahlman filter(HMA(price source, lookback), gain); otherwise HMA(price source, lookback)
Calculation: Modified average = if Kahlman filtering is enabled, Kahlman filter(Modified Hull average, gain); otherwise Modified Hull average
Long: Modified average > Price average AND Modified average[1] < Price average[1]
Short: Price average > Modified average AND Price average[1] < Modified average[1]