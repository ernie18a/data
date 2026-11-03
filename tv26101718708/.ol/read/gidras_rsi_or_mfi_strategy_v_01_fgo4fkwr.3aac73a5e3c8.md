Calculation: RSI/MFI Bollinger %B = (selected RSI or MFI value − lower band) / (upper band − lower band), where the bands are the moving average of that value plus/minus a standard-deviation multiple.
Long: Bollinger %B >= 0 AND previous bar’s Bollinger %B < 0 AND datetime is after the configured start datetime AND before the configured end datetime
Short: Bollinger %B <= 1 AND previous bar’s Bollinger %B > 1 AND datetime is after the configured start datetime AND before the configured end datetime
Exit: short, Bollinger %B >= 0 AND previous bar’s Bollinger %B < 0
Exit: long, Bollinger %B <= 1 AND previous bar’s Bollinger %B > 1
Exit: long, datetime > configured end datetime
Exit: short, datetime > configured end datetime