Calculation: Opening Range High = highest high during the opening range window
Calculation: Opening Range Low = lowest low during the opening range window
Calculation: Opening Range Width % = (Opening Range High − Opening Range Low) / close × 100
Calculation: Initial Risk = greater of the distance from entry price to the opposite opening range boundary and ATR × initial stop multiplier
Calculation: Long Stop = the greater of the previous stop and the greater of (highest high over the short structural lookback − ATR × trail multiplier) and the lowest low over that lookback
Calculation: Short Stop = the lesser of the previous stop and the lesser of (lowest low over the short structural lookback + ATR × trail multiplier) and the highest high over that lookback
Long: opening range is complete AND Opening Range Width % ≤ maximum allowed width AND current time is before the entry cutoff AND position is flat AND no long entry has occurred today AND close > Opening Range High
Short: opening range is complete AND Opening Range Width % ≤ maximum allowed width AND current time is before the entry cutoff AND position is flat AND no short entry has occurred today AND close < Opening Range Low
Exit: long, low ≤ Long Stop OR close < open AND open − close > ATR × reversal multiplier OR current time is within the square-off window
Exit: short, high ≥ Short Stop OR close > open AND close − open > ATR × reversal multiplier OR current time is within the square-off window