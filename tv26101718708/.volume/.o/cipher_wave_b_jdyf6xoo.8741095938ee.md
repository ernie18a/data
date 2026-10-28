Calculation: Fast WaveTrend = EMA(CI, longer lookback) × amplitude, where CI = (Heikin-Ashi HLC3 − EMA(Heikin-Ashi HLC3, channel lookback)) / (0.015 × EMA(abs(Heikin-Ashi HLC3 − EMA(Heikin-Ashi HLC3, channel lookback)), same channel lookback))
Calculation: WaveTrend signal = SMA(Fast WaveTrend, shorter lookback)
Long: Fast WaveTrend crosses above WaveTrend signal AND WaveTrend signal <= oversold dot threshold
Short: Fast WaveTrend crosses below WaveTrend signal AND WaveTrend signal >= overbought dot threshold