Calculation: Money flow volume = (close − open) / (high − low) × volume when (high − low) × volume > 0; otherwise 0
Calculation: Chaikin oscillator = EMA(longer-lookback rolling sum of money flow volume) − EMA(shorter-lookback rolling sum of money flow volume)
Long: (reverse disabled AND Chaikin oscillator > 0) OR (reverse enabled AND Chaikin oscillator < 0)
Short: (reverse disabled AND Chaikin oscillator < 0) OR (reverse enabled AND Chaikin oscillator > 0)