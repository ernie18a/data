Calculation: BestHour(indicator) = (atan2(Cum(sin(2π × hour(time, timezone) / 24) × indicator) / Cum(indicator), Cum(cos(2π × hour(time, timezone) / 24) × indicator) / Cum(indicator)) × 24 / (2π)) mod 24
Long: round(BestHour((RSI(close, length) + MFI(close, length)) / 2)) = hour(time, timezone)
Short: round(BestHour((RSI(1 / close, length) + MFI(1 / close, length)) / 2)) = hour(time, timezone)