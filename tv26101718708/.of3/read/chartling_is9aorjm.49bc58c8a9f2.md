Calculation: BandHigh = postMA(max(preMA(high, preLookback), HAOpen, HAClose), postLookback), where postLookback is longer than preLookback, HAOpen and HAClose are the open and close of HeikinAshi(preMA(open, preLookback), preMA(high, preLookback), preMA(low, preLookback), preMA(close, preLookback)), run on T1 bars and taken from the last completed T1 bar when T1 is higher than the chart timeframe, otherwise run on chart bars
Calculation: BandLow = postMA(min(preMA(low, preLookback), HAOpen, HAClose), postLookback), where postLookback is longer than preLookback, HAOpen and HAClose are the open and close of HeikinAshi(preMA(open, preLookback), preMA(high, preLookback), preMA(low, preLookback), preMA(close, preLookback)), run on T1 bars and taken from the last completed T1 bar when T1 is higher than the chart timeframe, otherwise run on chart bars
Calculation: Flow = flowMA(RawFlow, flowLookback), where RawFlow = 2*(open[1]+close[1]) - high - low - open, moved halfway toward low if below low and halfway toward high if above high
Long: low > BandHigh
Short: high < BandLow
Exit: long, low <= BandHigh AND high >= BandLow
Exit: short, low <= BandHigh AND high >= BandLow
Long: close >= Flow
Short: close < Flow