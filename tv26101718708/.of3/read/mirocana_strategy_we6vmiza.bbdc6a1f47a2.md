Calculation: return = (close(T1, still-forming bar) - close(T1, last completed bar)) / close(T1, last completed bar), evaluated on chart bars using T1 values
Long: return > threshold OR (return >= -threshold AND position side is long)
Short: return < -threshold OR (return <= threshold AND position side is short)