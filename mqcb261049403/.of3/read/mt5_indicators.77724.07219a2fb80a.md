Calculation: Body = abs(close-open)
Calculation: Range = high-low
Calculation: Body ratio = Body/Range
Calculation: Close location = (close-low)/Range
Long: close > open AND Body >= ATR(ATR lookback)*ATR multiplier AND Body ratio >= minimum body ratio AND Close location >= minimum close location AND (volume confirmation not required OR volume >= SMA(volume, volume lookback)[1]*volume multiplier)
Short: close < open AND Body >= ATR(ATR lookback)*ATR multiplier AND Body ratio >= minimum body ratio AND Close location <= 1-minimum close location AND (volume confirmation not required OR volume >= SMA(volume, volume lookback)[1]*volume multiplier)