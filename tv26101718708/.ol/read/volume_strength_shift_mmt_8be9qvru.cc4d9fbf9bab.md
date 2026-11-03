Calculation: Volume delta = volume × (2 × (close − low) ÷ (high − low) − 1); 0 when high = low
Calculation: Smoothed volume delta = configured moving average of volume delta
Calculation: Dominance threshold = configured fraction of the simple moving average of volume
Long: Smoothed volume delta > Dominance threshold AND previous Smoothed volume delta ≤ previous Dominance threshold OR Volume delta > previous Volume delta AND Volume delta > 0 AND Smoothed volume delta > Dominance threshold
Short: Smoothed volume delta < −Dominance threshold AND previous Smoothed volume delta ≥ −previous Dominance threshold OR Volume delta < previous Volume delta AND Volume delta < 0 AND Smoothed volume delta < −Dominance threshold