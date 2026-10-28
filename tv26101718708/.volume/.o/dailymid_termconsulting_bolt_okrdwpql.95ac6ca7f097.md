Calculation: MACD = shorter-lookback SMA of close minus longer-lookback SMA of close
Calculation: EFI signal = average of current and previous EFI, where EFI = (previous close − current close) × current volume / 1000
Calculation: Deviation = square root of the average of the current and previous squared differences between close and its 2-bar SMA, divided by 10
Long: previous low SMA < current low SMA AND previous high SMA < current high SMA AND MACD > 0 AND close > close SMA AND EFI signal < 9 AND close > a longer-lookback close SMA than the close SMA used above AND previous MACD < current MACD
Short: previous low SMA > current low SMA AND previous high SMA > current high SMA AND MACD < 0 AND close < close SMA AND EFI signal > 9 AND previous MACD > current MACD
Exit: long, EFI signal > 22000 AND close < close SMA
Exit: short, EFI signal < 14000 AND close > close SMA AND 14-bar SMA of close > Deviation