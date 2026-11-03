Calculation: WaveTrend = EMA of ((HLC3 − EMA(HLC3, channel lookback)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3, channel lookback)), same channel lookback)), using a longer smoothing lookback than the channel lookback
Long: WaveTrend crosses above 0 AND (EMA trend filter is disabled OR close > EMA)
Short: WaveTrend crosses below 0 AND (EMA trend filter is disabled OR close < EMA)
Exit: Long, low <= Parabolic SAR calculated on the current, still-forming higher-timeframe bar
Exit: Short, high >= Parabolic SAR calculated on the current, still-forming higher-timeframe bar