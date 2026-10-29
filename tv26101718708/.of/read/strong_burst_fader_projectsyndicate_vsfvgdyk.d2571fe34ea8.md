Calculation: Upper band = selected moving-average basis + band-width × ATR
Calculation: Lower band = selected moving-average basis − band-width × ATR
Calculation: Up-burst magnitude = max(0, (high − upper band) / ATR)
Calculation: Down-burst magnitude = max(0, (lower band − low) / ATR)
Calculation: Stack height = min(maximum stack height, 1 + integer part of burst magnitude / ATR-per-step)
Long: Down-burst magnitude > 0 AND Down-burst magnitude ≥ previous bar’s down-burst magnitude AND Down-burst magnitude > next bar’s down-burst magnitude AND Stack height ≥ fade-arrow threshold
Short: Up-burst magnitude > 0 AND Up-burst magnitude ≥ previous bar’s up-burst magnitude AND Up-burst magnitude > next bar’s up-burst magnitude AND Stack height ≥ fade-arrow threshold