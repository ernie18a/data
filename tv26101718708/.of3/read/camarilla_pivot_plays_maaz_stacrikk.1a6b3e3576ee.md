Calculation: CamarillaS3 = previous session close - level-3 range multiplier * (previous session high - previous session low)
Calculation: CamarillaR3 = previous session close + level-3 range multiplier * (previous session high - previous session low)
Calculation: RelativeVolume = volume / SMA(volume, average volume lookback), or 1.0 when SMA(volume, average volume lookback) is not positive
Calculation: LocationFlow = ((close - low) / (high - low) - 0.5) * flow scale * min(1, RelativeVolume / flow RVOL reference)
Long: low crosses below CamarillaS3 AND close > CamarillaS3
Long: close crosses above CamarillaR4(previous session high, previous session low, previous session close, level-4 range multiplier) AND (volume filter disabled OR RelativeVolume >= volume threshold) AND close > open
Long: previous session close > session-before-previous close
Long: LocationFlow > flow threshold
Long: LocationFlow(T1 bars, last completed T1 bar) > flow threshold
Long: LocationFlow(T2 bars, last completed T2 bar) > macro flow threshold
Short: high crosses above CamarillaR3 AND close < CamarillaR3
Short: close crosses below CamarillaS4(previous session high, previous session low, previous session close, level-4 range multiplier) AND (volume filter disabled OR RelativeVolume >= volume threshold) AND close < open
Short: previous session close < session-before-previous close
Short: LocationFlow < -flow threshold
Short: LocationFlow(T1 bars, last completed T1 bar) < -flow threshold
Short: LocationFlow(T2 bars, last completed T2 bar) < -macro flow threshold