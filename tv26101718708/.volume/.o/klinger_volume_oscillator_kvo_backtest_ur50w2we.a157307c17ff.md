Calculation: Volume force = volume × 100 if (high + low + close) / 3 > the previous bar’s (high + low + close) / 3; otherwise −volume × 100
Calculation: Klinger oscillator = shorter-period EMA of volume force − longer-period EMA of volume force
Calculation: Trigger = EMA of Klinger oscillator
Long: (reverse == false AND Klinger oscillator > Trigger) OR (reverse == true AND Klinger oscillator < Trigger)
Short: (reverse == false AND Klinger oscillator < Trigger) OR (reverse == true AND Klinger oscillator > Trigger)