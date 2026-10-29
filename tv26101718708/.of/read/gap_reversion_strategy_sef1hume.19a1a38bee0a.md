Calculation: Gap threshold = previous bar close × (1 − minimum gap percentage)
Calculation: Price-based limit = close × (1 − minimum gap percentage) × (1 − entry limit percentage)
Calculation: ATR-based limit = close × (1 − minimum gap percentage) − ATR × entry limit percentage
Calculation: Long stop price = entry price × (1 − stop percentage)
Long: RSI < entry threshold AND open < gap threshold AND low ≤ selected limit price
Exit: long, RSI > exit threshold OR low ≤ long stop price