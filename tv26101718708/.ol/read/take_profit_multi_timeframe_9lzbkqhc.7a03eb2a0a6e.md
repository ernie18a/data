Calculation: WaveTrend = EMA((HLC3 − EMA(HLC3, channel length)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3, channel length)), channel length)), average length)
Calculation: WaveTrend signal = SMA(WaveTrend, 4)
Calculation: Higher-timeframe EMA levels = EMA of close on each of two higher timeframes, using each timeframe’s last completed bar; on each timeframe calculate a shorter-lookback EMA and a longer-lookback EMA
Calculation: Ranked EMA targets = the lowest, second-lowest, and third-lowest of the four higher-timeframe EMA levels
Long: WaveTrend crosses above WaveTrend signal AND WaveTrend is below the oversold threshold
Exit: Long, WaveTrend crosses below WaveTrend signal AND WaveTrend is above zero OR low reaches the entry price minus the configured stop-loss percentage OR high reaches any configured percentage take-profit level above the entry price OR the highest of the four higher-timeframe EMA levels is above the entry price AND high reaches any of the three ranked EMA targets
