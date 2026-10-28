Calculation: ATR envelope = selected moving-average basis ± band width × ATR.
Calculation: Burst magnitude = max(0, wick overshoot beyond the corresponding ATR envelope ÷ ATR); when the closing-burst filter is enabled, require the close beyond that envelope.
Calculation: Confirmed burst peak = the previous bar has positive burst magnitude, its magnitude is at least that of the bar two bars earlier and greater than the current bar’s magnitude; confirm at the current bar’s close.
Calculation: Stack height = min(maximum stack height, 1 + floor(peak burst magnitude ÷ ATR-per-step)).
Long: Confirmed down-burst peak AND stack height ≥ configured fade-arrow minimum AND peak bar close > lower ATR envelope.
Short: Confirmed up-burst peak AND stack height ≥ configured fade-arrow minimum AND peak bar close < upper ATR envelope.
Exit: Long, low ≤ burst low OR high ≥ moving-average basis.
Exit: Short, high ≥ burst high OR low ≤ moving-average basis.