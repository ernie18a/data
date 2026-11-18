Calculation: delayed long-period weighted-average blend = WMA(2 × WMA(close, rounded half of longer lookback) − WMA(close, longer lookback), rounded square root of shorter lookback)[2]
Long: HMA(close, shorter lookback) crosses above HMA(close, shorter lookback)[1]
Short: HMA(close, shorter lookback) crosses below HMA(close, shorter lookback)[1]
Long: VWMA(close, shorter lookback) crosses VWMA(close, medium lookback) AND VWMA(close, medium lookback) > VWMA(close, longer lookback)
Short: VWMA(close, shorter lookback) crosses VWMA(close, medium lookback) AND VWMA(close, medium lookback) <= VWMA(close, longer lookback)
Long: position is flat AND HMA(close, shorter lookback) > HMA(close, shorter lookback)[1] AND HMA(close, shorter lookback) < delayed long-period weighted-average blend
Short: position is flat AND HMA(close, shorter lookback) < HMA(close, shorter lookback)[1] AND HMA(close, shorter lookback) > delayed long-period weighted-average blend
Exit: long, HMA(close, shorter lookback) < HMA(close, shorter lookback)[1]
Exit: short, HMA(close, shorter lookback) > HMA(close, shorter lookback)[1]