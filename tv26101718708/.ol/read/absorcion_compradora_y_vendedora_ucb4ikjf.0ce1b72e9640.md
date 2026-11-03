Calculation: Estimated buyer volume = volume × (close − low) / (high − low) when high > low; otherwise 0
Calculation: Estimated seller volume = volume × (high − close) / (high − low) when high > low; otherwise 0
Calculation: Buyer volume ratio = estimated buyer volume / volume when volume > 0; otherwise 0
Calculation: Seller volume ratio = estimated seller volume / volume when volume > 0; otherwise 0
Long: high > low AND abs(close − open) / (high − low) < maximum body-to-range ratio AND volume > simple moving average of volume over a lookback × volume multiplier AND buyer volume ratio > minimum dominance ratio
Short: high > low AND abs(close − open) / (high − low) < maximum body-to-range ratio AND volume > simple moving average of volume over a lookback × volume multiplier AND seller volume ratio > minimum dominance ratio