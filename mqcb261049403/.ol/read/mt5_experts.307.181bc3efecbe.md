Calculation: Bar 1 is the latest completed chart-timeframe bar; bar 2 is the preceding completed chart-timeframe bar. All calculations use chart-timeframe bars.
Calculation: Average body = mean of |open − close| over the lookback starting at the referenced bar and continuing to older bars; its lookback equals the close SMA lookback.
Calculation: Bullish engulfing = bar 2 open > close AND bar 1 close − open > average body at bar 1 AND bar 1 close > bar 2 open AND midpoint of bar 2 open and close < close SMA at bar 2 AND bar 1 open < bar 2 close.
Calculation: Bearish engulfing = bar 2 open < close AND bar 1 open − close > average body at bar 1 AND bar 1 close < bar 2 open AND midpoint of bar 2 open and close > close SMA at bar 2 AND bar 1 open > bar 2 close.
Long: bullish engulfing AND MFI at bar 1 < 40
Short: bearish engulfing AND MFI at bar 1 > 60
Exit: short, (MFI at bar 1 > 30 AND MFI at bar 2 < 30) OR (MFI at bar 1 > 70 AND MFI at bar 2 < 70)
Exit: long, (MFI at bar 1 > 70 AND MFI at bar 2 < 70) OR (MFI at bar 1 < 30 AND MFI at bar 2 > 30)