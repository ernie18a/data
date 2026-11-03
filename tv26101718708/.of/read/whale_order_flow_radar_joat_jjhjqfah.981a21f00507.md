Calculation: Close position = (close - low) / (high - low) when high > low; otherwise 0.5.
Calculation: Volume z-score = (volume - SMA(volume)) / standard deviation of volume over the same lookback when that standard deviation > 0; otherwise 0.
Calculation: Delta proxy = volume × (2 × close position - 1).
Calculation: Pressure = EMA(delta proxy / SMA(volume)) using the same volume lookback as the volume z-score; use 0 for the EMA input when the volume SMA is not positive.
Calculation: Confirmed long signal = volume z-score >= whale threshold AND close position >= 1 - conviction fraction AND pressure > 0 AND (trend filter disabled OR close >= EMA(close)) AND (no previous confirmed signal OR bars since the most recent confirmed long or short signal >= minimum signal spacing).
Calculation: Confirmed short signal = volume z-score >= whale threshold AND close position <= conviction fraction AND pressure < 0 AND (trend filter disabled OR close < EMA(close)) AND (no previous confirmed signal OR bars since the most recent confirmed long or short signal >= minimum signal spacing).
Calculation: Entry risk = ATR at the signal bar × stop multiplier; retain this value for the position.
Long: volume z-score >= whale threshold AND close position >= 1 - conviction fraction.
Short: volume z-score >= whale threshold AND close position <= conviction fraction.
Long: confirmed long signal = true.
Short: confirmed short signal = true.
Long: pressure >= 0.
Short: pressure < 0.
Long: close >= EMA(close).
Short: close < EMA(close).
Exit: long, high >= entry price + entry risk × first target multiplier OR low <= entry price - entry risk OR confirmed long signal = true OR confirmed short signal = true.
Exit: short, low <= entry price - entry risk × first target multiplier OR high >= entry price + entry risk OR confirmed long signal = true OR confirmed short signal = true.