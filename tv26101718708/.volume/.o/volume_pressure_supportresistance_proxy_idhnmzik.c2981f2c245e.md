Calculation: support = latest confirmed pivot low using a lookback and confirmation window of equal length
Calculation: resistance = latest confirmed pivot high using a lookback and confirmation window of equal length
Calculation: high volume = volume > volume moving average × multiplier
Calculation: close position = (close − low) / (high − low), or 0.5 when high = low
Long: close crosses above resistance AND high volume AND close > low + (high − low) × strong-close threshold AND (high − low = 0 OR close position > 0.5)
Long: (low ≤ support × 1.01 OR low crosses below support) AND high volume AND close > low + (high − low) × strong-close threshold AND (high − low = 0 OR close position > 0.5)
Short: close crosses below support AND high volume AND close < low + (high − low) × weak-close threshold AND (high − low = 0 OR close position < 0.5)
Short: (high ≥ resistance × 0.99 OR high crosses above resistance) AND high volume AND close < low + (high − low) × weak-close threshold AND (high − low = 0 OR close position < 0.5)