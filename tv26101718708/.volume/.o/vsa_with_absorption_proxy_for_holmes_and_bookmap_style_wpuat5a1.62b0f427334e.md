Calculation: Directional volume proxy = volume × (close − open) / (high − low)
Calculation: Average proxy delta = SMA(directional volume proxy, lookback)
Calculation: High volume = volume > SMA(volume, lookback) × multiplier
Long: High volume AND close > open AND directional volume proxy > average proxy delta AND previous bar directional volume proxy < previous bar average proxy delta
Short: High volume AND close < open AND directional volume proxy < average proxy delta AND previous bar directional volume proxy > previous bar average proxy delta
Exit: long, price ≤ current bar low × (1 − risk percentage) OR price ≥ current bar close × (1 + risk percentage × reward/risk target)
Exit: short, price ≥ current bar high × (1 + risk percentage) OR price ≤ current bar close × (1 − risk percentage × reward/risk target)