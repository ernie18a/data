Calculation: Volume delta = (volume if (close − low) > (high − close) OR ((close − low) = (high − close) AND close > open), otherwise 0) − (volume if (close − low) < (high − close) OR ((close − low) = (high − close) AND close < open), otherwise 0)
Calculation: Volume-flow oscillator = EMA of volume delta
Calculation: Signal line = SMA of volume-flow oscillator
Long: Volume-flow oscillator crosses above signal line AND volume-flow oscillator < 0
Short: Volume-flow oscillator crosses below signal line AND volume-flow oscillator > 0