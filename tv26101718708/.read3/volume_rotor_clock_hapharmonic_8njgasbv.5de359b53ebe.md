Calculation: UpVolume = volume * (close - low) / (high - low) if high > low else volume / 2
Calculation: DownVolume = volume * (high - close) / (high - low) if high > low else volume / 2
Long: SUM(UpVolume, lookback + 1) >= SUM(DownVolume, lookback + 1)
Short: SUM(DownVolume, lookback + 1) > SUM(UpVolume, lookback + 1)
Long: SUM(scanned UpVolume, lookback + 1) > SUM(scanned DownVolume, lookback + 1)
Short: SUM(scanned DownVolume, lookback + 1) > SUM(scanned UpVolume, lookback + 1)
Long: SUM(scanned UpVolume, lookback + 1) > SUM(scanned DownVolume, lookback + 1) AND BarsSince(NOT(scanned volume > SMA(scanned volume, volume average length))) >= consecutive bars