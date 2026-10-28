Calculation: Normalized CCI = rescale CCI to 0–100 using its rolling minimum and maximum over a lookback twice the CCI lookback; use 50 if the range is zero
Calculation: Normalized ROC = rescale ROC to 0–100 using its rolling minimum and maximum over a lookback twice the ROC lookback; use 50 if the range is zero
Calculation: Normalized MACD histogram = rescale the MACD histogram to 0–100 using its rolling minimum and maximum over a lookback twice the MACD slow EMA lookback; use 50 if the range is zero
Calculation: Normalized Williams %R = Williams %R + 100
Calculation: DMI balance = DI+ / (DI+ + DI−) × 100; use 50 if the denominator is zero
Calculation: Aroon balance = (Aroon Up − Aroon Down + 100) / 2
Calculation: Bull count = number of bullish votes among RSI, Stochastic, Normalized CCI, MFI, Normalized Williams %R, Normalized ROC, Ultimate Oscillator, Normalized MACD histogram, DMI balance, and Aroon balance; a value at or above the bullish threshold votes bullish
Calculation: Bear count = number of bearish votes among RSI, Stochastic, Normalized CCI, MFI, Normalized Williams %R, Normalized ROC, Ultimate Oscillator, Normalized MACD histogram, DMI balance, and Aroon balance; a value at or below the bearish threshold votes bearish
Calculation: Agreement percentage = max(bull count, bear count) × 10
Calculation: Regime = bullish if bull count ≥ consensus threshold; otherwise bearish if bear count ≥ consensus threshold; otherwise divergent if |bull count − bear count| ≤ 2; otherwise transition
Long: current regime = bullish AND previous regime ≠ bullish OR current agreement percentage ≥ extreme agreement threshold AND previous agreement percentage < extreme agreement threshold AND bull count ≥ bear count
Short: current regime = bearish AND previous regime ≠ bearish OR current agreement percentage ≥ extreme agreement threshold AND previous agreement percentage < extreme agreement threshold AND bear count > bull count
Exit: long, current regime = bearish AND previous regime = bullish
Exit: short, current regime = bullish AND previous regime = bearish