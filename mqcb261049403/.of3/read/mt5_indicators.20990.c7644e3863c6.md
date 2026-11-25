Calculation: SoT = if volume != 0 then ((close - open) / volume) * scale else 0
Long: close > open AND SoT >= SMA(SoT, Period) * Multiplier
Short: close < open AND SoT >= SMA(SoT, Period) * Multiplier