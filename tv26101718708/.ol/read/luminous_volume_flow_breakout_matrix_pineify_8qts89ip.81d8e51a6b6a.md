Calculation: EMA-smoothed proportional volume delta = EMA of volume × (close − low − (high − close)) ÷ (high − low); use zero when high = low
Calculation: Volume surge threshold = recent mean volume + configurable multiplier × recent volume standard deviation
Long: volume > volume surge threshold AND EMA-smoothed proportional volume delta > 0
Short: volume > volume surge threshold AND EMA-smoothed proportional volume delta < 0